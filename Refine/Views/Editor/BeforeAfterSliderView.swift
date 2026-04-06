import SwiftUI

/// Before/After 比較UI
struct BeforeAfterSliderView: View {
    let beforeImage: UIImage
    let afterImage: UIImage?
    let showBefore: Bool
    @Binding var compareMode: Bool
    @Binding var sliderPosition: CGFloat

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let displayImage = showBefore ? beforeImage : (afterImage ?? beforeImage)

            ZStack {
                if compareMode, let afterImg = afterImage {
                    // スライダー比較モード
                    compareView(before: beforeImage, after: afterImg, size: size)
                } else {
                    // 通常表示
                    Image(uiImage: displayImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: size.width, maxHeight: size.height)
                }

                // Before ラベル
                if showBefore {
                    VStack {
                        HStack {
                            Text("Before")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.black.opacity(0.5))
                                .clipShape(Capsule())
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func compareView(before: UIImage, after: UIImage, size: CGSize) -> some View {
        ZStack {
            // After (背面に全画面)
            Image(uiImage: after)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: size.width, maxHeight: size.height)

            // Before (クリッピング)
            Image(uiImage: before)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: size.width, maxHeight: size.height)
                .clipShape(
                    HorizontalClip(position: sliderPosition)
                )

            // スライダーライン
            Rectangle()
                .fill(.white)
                .frame(width: 2)
                .position(x: size.width * sliderPosition, y: size.height / 2)
                .shadow(color: .black.opacity(0.3), radius: 2)

            // スライダーハンドル
            Circle()
                .fill(.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.2), radius: 4)
                .overlay(
                    Image(systemName: "arrow.left.and.right")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                )
                .position(x: size.width * sliderPosition, y: size.height / 2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            sliderPosition = max(0.05, min(0.95, value.location.x / size.width))
                        }
                )

            // ラベル
            HStack {
                Text("Before")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.4))
                    .clipShape(Capsule())
                Spacer()
                Text("After")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.4))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 8)
        }
    }
}

/// 水平方向でクリップするShape
struct HorizontalClip: Shape {
    var position: CGFloat

    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path(CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width * position,
            height: rect.height
        ))
    }
}
