import CoreGraphics
import UIKit

extension CGPoint {
    /// 2点間の距離
    func distance(to other: CGPoint) -> CGFloat {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }

    /// 2点の中点
    func midpoint(to other: CGPoint) -> CGPoint {
        CGPoint(x: (x + other.x) / 2, y: (y + other.y) / 2)
    }
}

// MARK: - スプライン補間 & マスク描画ユーティリティ

enum LandmarkPathHelper {

    /// Catmull-Rom スプライン補間でなめらかな UIBezierPath を生成
    /// - closed: true なら閉じたパス（唇など）、false なら開いたパス（眉など）
    static func smoothPath(from points: [CGPoint], closed: Bool, tension: CGFloat = 0.5) -> UIBezierPath {
        let path = UIBezierPath()
        guard points.count >= 3 else {
            if let first = points.first {
                path.move(to: first)
                for p in points.dropFirst() { path.addLine(to: p) }
                if closed { path.close() }
            }
            return path
        }

        let pts: [CGPoint]
        if closed {
            // 閉じたパス: 先頭と末尾を折り返して補間点を追加
            pts = [points[points.count - 1]] + points + [points[0], points[1]]
        } else {
            // 開いたパス: 端点を複製
            pts = [points[0]] + points + [points[points.count - 1]]
        }

        path.move(to: pts[1])

        let segmentCount = closed ? points.count : points.count - 1
        for i in 1...segmentCount {
            let p0 = pts[i - 1]
            let p1 = pts[i]
            let p2 = pts[i + 1]
            let p3 = pts[min(i + 2, pts.count - 1)]

            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / (6.0 / tension),
                y: p1.y + (p2.y - p0.y) / (6.0 / tension)
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / (6.0 / tension),
                y: p2.y - (p3.y - p1.y) / (6.0 / tension)
            )
            path.addCurve(to: p2, controlPoint1: cp1, controlPoint2: cp2)
        }

        if closed { path.close() }
        return path
    }

    /// 点群からグラデーション付きマスク CIImage を生成
    /// - blurSigma: エッジのぼかし量
    static func gradientMask(
        from points: [CGPoint],
        closed: Bool,
        imageSize: CGSize,
        blurSigma: CGFloat,
        expandRatio: CGFloat = 0.0
    ) -> CIImage? {
        guard points.count >= 3 else { return nil }

        var drawPoints = points
        if expandRatio != 0.0 {
            let center = CGPoint(
                x: points.map(\.x).reduce(0, +) / CGFloat(points.count),
                y: points.map(\.y).reduce(0, +) / CGFloat(points.count)
            )
            drawPoints = points.map { p in
                CGPoint(
                    x: center.x + (p.x - center.x) * (1.0 + expandRatio),
                    y: center.y + (p.y - center.y) * (1.0 + expandRatio)
                )
            }
        }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))

        let path = smoothPath(from: drawPoints, closed: closed)
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))
        ctx.addPath(path.cgPath)
        ctx.fillPath()

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let ciImage = img.toCIImage() else { return nil }
        return ciImage.applyingGaussianBlur(sigma: blurSigma)
    }

    /// 眉用: 太さが自然に変化するマスクを生成（中央太め、端細め）
    static func eyebrowMask(
        points: [CGPoint],
        imageSize: CGSize,
        baseThickness: CGFloat,
        blurSigma: CGFloat
    ) -> CIImage? {
        guard points.count >= 3 else { return nil }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        // 各点に太さの重みをつける (中央が太く端が細い)
        let count = points.count
        var upperPoints: [CGPoint] = []
        var lowerPoints: [CGPoint] = []

        for i in 0..<count {
            let t = CGFloat(i) / CGFloat(count - 1)
            // sin カーブで中央を太く
            let thicknessFactor = sin(t * .pi) * 0.7 + 0.3
            let thickness = baseThickness * thicknessFactor

            // 前後の点から法線方向を求める
            let prev = points[max(0, i - 1)]
            let next = points[min(count - 1, i + 1)]
            let dx = next.x - prev.x
            let dy = next.y - prev.y
            let len = sqrt(dx * dx + dy * dy)
            guard len > 0 else { continue }
            let nx = -dy / len
            let ny = dx / len

            upperPoints.append(CGPoint(
                x: points[i].x + nx * thickness,
                y: points[i].y + ny * thickness
            ))
            lowerPoints.append(CGPoint(
                x: points[i].x - nx * thickness,
                y: points[i].y - ny * thickness
            ))
        }

        // 上側 + 下側逆順 で閉じたパスを作る
        let allPoints = upperPoints + lowerPoints.reversed()
        let path = smoothPath(from: allPoints, closed: true, tension: 0.4)
        ctx.addPath(path.cgPath)
        ctx.fillPath()

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let ciImage = img.toCIImage() else { return nil }
        return ciImage.applyingGaussianBlur(sigma: blurSigma)
    }
}
