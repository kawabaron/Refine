import SwiftUI
import Combine

/// メイン編集画面の状態管理
@MainActor
final class EditorViewModel: ObservableObject {

    // MARK: - Published State

    let originalImage: UIImage
    @Published var previewImage: UIImage?
    @Published var faceDetectionResult: FaceDetectionResult?
    @Published var editParameters: EditParameters = .default
    @Published var selectedCategory: EditorCategory = .skin
    @Published var isProcessing = false
    @Published var isSaving = false
    @Published var showBeforeImage = false
    @Published var compareModeEnabled = false
    @Published var compareSliderPosition: CGFloat = 0.5
    @Published var currentError: AppError?
    @Published var showPresetSheet = false
    @Published var showExportResult = false
    @Published var savedImage: UIImage?
    @Published var comparisonImage: UIImage?

    // MARK: - Services

    private let faceDetectionService = FaceDetectionService()
    private let editingPipeline = ImageEditingPipeline()
    private let photoSaveService = PhotoSaveService()
    private let comparisonImageService = ComparisonImageService()

    // MARK: - Debounce

    private var renderTask: Task<Void, Never>?
    private var parameterSubject = PassthroughSubject<EditParameters, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(originalImage: UIImage) {
        self.originalImage = originalImage.normalizedOrientation()
        setupDebounce()
    }

    private func setupDebounce() {
        parameterSubject
            .debounce(for: .milliseconds(Int(Constants.UI.sliderDebounceInterval * 1000)), scheduler: RunLoop.main)
            .sink { [weak self] params in
                self?.performRender(with: params)
            }
            .store(in: &cancellables)
    }

    // MARK: - Lifecycle

    func onAppear() {
        previewImage = originalImage
        detectFaceIfNeeded()
    }

    // MARK: - Face Detection

    func detectFaceIfNeeded() {
        guard faceDetectionResult == nil else { return }
        isProcessing = true

        Task {
            do {
                let result = try await faceDetectionService.detectFace(in: originalImage)
                faceDetectionResult = result
                currentError = nil
                // 初回の自動レンダリング
                await renderPreview()
            } catch let error as AppError {
                currentError = error
            } catch {
                currentError = .faceNotFound
            }
            isProcessing = false
        }
    }

    // MARK: - Parameter Updates

    func updateParameter(_ keyPath: WritableKeyPath<EditParameters, Double>, value: Double) {
        editParameters[keyPath: keyPath] = value
        parameterSubject.send(editParameters)
    }

    func updateLipColorPreset(_ preset: LipColorPreset) {
        editParameters.lipColorPreset = preset
        parameterSubject.send(editParameters)
    }

    func updateEyeShadowPreset(_ preset: EyeShadowPreset) {
        editParameters.eyeShadowPreset = preset
        parameterSubject.send(editParameters)
    }

    func toggleNaturalMode() {
        editParameters.naturalModeEnabled.toggle()
        parameterSubject.send(editParameters)
    }

    // MARK: - Preset

    func applyPreset(_ preset: EditPreset) {
        editParameters = preset.parameters
        parameterSubject.send(editParameters)
        showPresetSheet = false
    }

    // MARK: - Reset

    func resetAdjustments() {
        editParameters = .default
        parameterSubject.send(editParameters)
    }

    // MARK: - Category

    func setCategory(_ category: EditorCategory) {
        selectedCategory = category
    }

    // MARK: - Rendering

    func renderPreview() async {
        guard let faceResult = faceDetectionResult else { return }
        isProcessing = true

        let result = await editingPipeline.process(
            originalImage: originalImage,
            faceResult: faceResult,
            parameters: editParameters
        )

        previewImage = result ?? originalImage
        isProcessing = false
    }

    private func performRender(with params: EditParameters) {
        renderTask?.cancel()
        renderTask = Task {
            guard let faceResult = faceDetectionResult else { return }
            isProcessing = true

            let result = await editingPipeline.process(
                originalImage: originalImage,
                faceResult: faceResult,
                parameters: params
            )

            if !Task.isCancelled {
                previewImage = result ?? originalImage
                isProcessing = false
            }
        }
    }

    // MARK: - Save

    func saveEditedImage() {
        guard let previewImage else { return }
        isSaving = true

        Task {
            do {
                // 高解像度で再レンダリング
                if let faceResult = faceDetectionResult {
                    let highRes = await editingPipeline.process(
                        originalImage: originalImage,
                        faceResult: faceResult,
                        parameters: editParameters
                    )
                    savedImage = highRes ?? previewImage
                } else {
                    savedImage = previewImage
                }

                try await photoSaveService.save(savedImage!)
                showExportResult = true
            } catch let error as AppError {
                currentError = error
            } catch {
                currentError = .saveFailed
            }
            isSaving = false
        }
    }

    // MARK: - Comparison Image

    func makeComparisonImage() -> UIImage? {
        guard let previewImage else { return nil }
        return comparisonImageService.generateSideBySide(
            before: originalImage,
            after: previewImage
        )
    }

    func saveComparisonImage() {
        isSaving = true

        Task {
            do {
                guard let comparison = makeComparisonImage() else {
                    currentError = .processingFailed("比較画像の生成に失敗しました")
                    isSaving = false
                    return
                }
                comparisonImage = comparison
                try await photoSaveService.save(comparison)
            } catch let error as AppError {
                currentError = error
            } catch {
                currentError = .saveFailed
            }
            isSaving = false
        }
    }

    // MARK: - Error

    func dismissError() {
        currentError = nil
    }
}
