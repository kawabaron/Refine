import SwiftUI

/// メイン編集画面
struct EditorView: View {
    @StateObject private var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(originalImage: UIImage) {
        _viewModel = StateObject(wrappedValue: EditorViewModel(originalImage: originalImage))
    }

    var body: some View {
        ZStack {
            Constants.Colors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 上部バー
                EditorTopBar(
                    onBack: { dismiss() },
                    onReset: { viewModel.resetAdjustments() }
                )

                // 画像表示エリア
                imageArea
                    .frame(maxHeight: .infinity)

                // 比較モードトグル
                compareModeBar

                // カテゴリタブ
                CategoryTabBarView(
                    selectedCategory: $viewModel.selectedCategory,
                    onSelect: { viewModel.setCategory($0) }
                )

                // 調整UIエリア
                adjustmentArea
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                // 下部アクション
                bottomActions
            }

            // ローディング
            if viewModel.isProcessing {
                LoadingOverlayView(message: "処理中…")
                    .allowsHitTesting(false)
            }

            if viewModel.isSaving {
                LoadingOverlayView(message: "保存中…")
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.onAppear() }
        .overlay(alignment: .top) {
            if let error = viewModel.currentError {
                ErrorBannerView(
                    error: error,
                    onDismiss: { viewModel.dismissError() },
                    onRetry: error == .faceNotFound ? { viewModel.detectFaceIfNeeded() } : nil
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 52)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentError)
        .sheet(isPresented: $viewModel.showPresetSheet) {
            PresetSheetView { preset in
                viewModel.applyPreset(preset)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showExportResult) {
            ExportResultView(
                savedImage: viewModel.savedImage,
                originalImage: viewModel.originalImage,
                onSaveComparison: { viewModel.saveComparisonImage() },
                onDismiss: { viewModel.showExportResult = false }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Image Area

    private var imageArea: some View {
        BeforeAfterSliderView(
            beforeImage: viewModel.originalImage,
            afterImage: viewModel.previewImage,
            showBefore: viewModel.showBeforeImage,
            compareMode: $viewModel.compareModeEnabled,
            sliderPosition: $viewModel.compareSliderPosition
        )
        .padding(.horizontal, 8)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.15)
                .onChanged { _ in
                    viewModel.showBeforeImage = true
                }
        )
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            viewModel.showBeforeImage = pressing
        }, perform: {})
    }

    // MARK: - Compare Mode Bar

    private var compareModeBar: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.compareModeEnabled.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.compareModeEnabled ? "rectangle.split.2x1.fill" : "rectangle.split.2x1")
                        .font(.caption)
                    Text("比較")
                        .font(.caption)
                }
                .foregroundStyle(viewModel.compareModeEnabled ? Constants.Colors.accent : .secondary)
            }

            Text("長押しで Before 表示")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - Adjustment Area

    @ViewBuilder
    private var adjustmentArea: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                switch viewModel.selectedCategory {
                case .skin:
                    skinAdjustments
                case .complexion:
                    complexionAdjustments
                case .eyebrow:
                    eyebrowAdjustments
                case .beard:
                    beardAdjustments
                case .lips:
                    lipAdjustments
                case .eyes:
                    eyeAdjustments
                }
            }
            .padding(.vertical, 4)
        }
        .frame(height: 160)
    }

    private var skinAdjustments: some View {
        VStack(spacing: 12) {
            AdjustmentSliderView(
                title: "なめらかさ",
                value: $viewModel.editParameters.skinSmooth,
                labels: ("弱め", "標準", "強め")
            ) { value in
                viewModel.updateParameter(\.skinSmooth, value: value)
            }

            AdjustmentSliderView(
                title: "トーン",
                value: $viewModel.editParameters.skinTone
            ) { value in
                viewModel.updateParameter(\.skinTone, value: value)
            }

            AdjustmentSliderView(
                title: "クマ軽減",
                value: $viewModel.editParameters.darkCircleReduction
            ) { value in
                viewModel.updateParameter(\.darkCircleReduction, value: value)
            }
        }
    }

    private var complexionAdjustments: some View {
        AdjustmentSliderView(
            title: "血色",
            value: $viewModel.editParameters.complexion,
            labels: ("弱め", "標準", "強め")
        ) { value in
            viewModel.updateParameter(\.complexion, value: value)
        }
    }

    private var eyebrowAdjustments: some View {
        VStack(spacing: 12) {
            AdjustmentSliderView(
                title: "濃さ",
                value: $viewModel.editParameters.eyebrowIntensity
            ) { value in
                viewModel.updateParameter(\.eyebrowIntensity, value: value)
            }

            AdjustmentSliderView(
                title: "形補正",
                value: $viewModel.editParameters.eyebrowShapeCorrection
            ) { value in
                viewModel.updateParameter(\.eyebrowShapeCorrection, value: value)
            }
        }
    }

    private var beardAdjustments: some View {
        AdjustmentSliderView(
            title: "青ひげ軽減",
            value: $viewModel.editParameters.beardReduction,
            labels: ("弱め", "標準", "強め")
        ) { value in
            viewModel.updateParameter(\.beardReduction, value: value)
        }
    }

    private var lipAdjustments: some View {
        VStack(spacing: 12) {
            ColorPresetPickerView<LipColorPreset>(
                title: "カラー",
                selected: $viewModel.editParameters.lipColorPreset,
                colorFor: { $0.color },
                nameFor: { $0.displayName },
                onChange: { viewModel.updateLipColorPreset($0) }
            )

            AdjustmentSliderView(
                title: "濃さ",
                value: $viewModel.editParameters.lipColorIntensity
            ) { value in
                viewModel.updateParameter(\.lipColorIntensity, value: value)
            }
        }
    }

    private var eyeAdjustments: some View {
        VStack(spacing: 12) {
            ColorPresetPickerView<EyeShadowPreset>(
                title: "カラー",
                selected: $viewModel.editParameters.eyeShadowPreset,
                colorFor: { $0.color },
                nameFor: { $0.displayName },
                onChange: { viewModel.updateEyeShadowPreset($0) }
            )

            AdjustmentSliderView(
                title: "濃さ",
                value: $viewModel.editParameters.eyeShadowIntensity
            ) { value in
                viewModel.updateParameter(\.eyeShadowIntensity, value: value)
            }
        }
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        HStack(spacing: 12) {
            NaturalModeToggleView(
                isEnabled: $viewModel.editParameters.naturalModeEnabled,
                onToggle: { viewModel.toggleNaturalMode() }
            )

            Button {
                viewModel.showPresetSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "wand.and.stars")
                        .font(.caption)
                    Text("プリセット")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.08))
                .clipShape(Capsule())
            }
            .foregroundStyle(Constants.Colors.primaryNavy)

            Spacer()

            Button {
                viewModel.saveEditedImage()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.caption)
                    Text("保存")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Constants.Colors.accent)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .disabled(viewModel.isSaving || viewModel.faceDetectionResult == nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
