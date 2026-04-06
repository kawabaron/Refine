import CoreGraphics

extension CGRect {
    /// CGRect の中心点
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    /// 指定割合で拡大した矩形
    func expanded(by ratio: CGFloat) -> CGRect {
        let dw = width * ratio
        let dh = height * ratio
        return insetBy(dx: -dw / 2, dy: -dh / 2)
    }
}
