import SwiftUI

/// 参考 https://uvolchyk.medium.com/sparkling-shiny-things-with-metal-and-swiftui-cba69c730a24
extension View {
    func shiny(
        at point: CGPoint
    ) -> some View {
        modifier(
            Shiny(point: point)
        )
    }
}

private struct Shiny: ViewModifier {
    let point: CGPoint

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.visualEffect { view, proxy in
                view.colorEffect(
                    ShaderLibrary.default.shiny(
                        .float2(point),
                        .float2(proxy.size)
                    )
                )
            }
            .animation(.linear, value: point)
        } else {
            content
        }
    }
}

extension View where Self: Shape {
    fileprivate func glowBorder(
        fill: some ShapeStyle,
        lineWidth: Double = 4,
        blurRadius: Double = 8,
        lineCap: CGLineCap = .round
    ) -> some View {
        stroke(
            style: .init(lineWidth: lineWidth / 2, lineCap: lineCap)
        )
        .fill(fill)
        .overlay {
            self.stroke(style: .init(lineWidth: lineWidth, lineCap: lineCap))
                .fill(fill)
                .blur(radius: blurRadius)
        }
        .overlay {
            self.stroke(style: .init(lineWidth: lineWidth, lineCap: lineCap))
                .fill(fill)
                .blur(radius: blurRadius / 2)
        }
    }
}

extension ShapeStyle where Self == AngularGradient {
    fileprivate static var palette: some ShapeStyle {
        .angularGradient(
            stops: [
                .init(color: .blue, location: 0.0),
                .init(color: .purple, location: 0.2),
                .init(color: .red, location: 0.4),
                .init(color: .mint, location: 0.5),
                .init(color: .indigo, location: 0.7),
                .init(color: .pink, location: 0.9),
                .init(color: .blue, location: 1.0),
            ],
            center: .center,
            startAngle: .init(radians: .zero),
            endAngle: .init(radians: .pi * 2)
        )
    }
}

extension CGRect {
    fileprivate func roundedRectPoints(
        cornerRadius: CGFloat,
        proposedNumberOfPoints: Int
    ) -> [CGPoint] {
        var points: [CGPoint] = []

        // 计算四个圆角的中心点
        let corners: [CGPoint] = [
            .init(x: minX + cornerRadius, y: minY + cornerRadius), // 左下角
            .init(x: maxX - cornerRadius, y: minY + cornerRadius), // 右下角
            .init(x: maxX - cornerRadius, y: maxY - cornerRadius), // 右上角
            .init(x: minX + cornerRadius, y: maxY - cornerRadius), // 左上角
        ]

        // 计算四条直线边的长度
        let straightEdges: [CGFloat] = [
            width - 2 * cornerRadius, // 底边
            height - 2 * cornerRadius, // 右边
            width - 2 * cornerRadius, // 顶边
            height - 2 * cornerRadius, // 左边
        ]

        // 计算圆角矩形的总周长
        let perimeter: CGFloat = 2 * .pi * cornerRadius + 2 * straightEdges.reduce(0, +)

        // 计算每个部分的点数
        let pointsPerSection = straightEdges
            .map { Int(CGFloat(proposedNumberOfPoints) * $0 / perimeter) }
        let pointsPerArc = Int(CGFloat(proposedNumberOfPoints) * (.pi * cornerRadius) / perimeter)

        // 底边
        for i in 0..<pointsPerSection[0] {
            let t = CGFloat(i) / CGFloat(pointsPerSection[0])

            points.append(
                .init(
                    x: minX + cornerRadius + t * (width - 2 * cornerRadius),
                    y: minY
                )
            )
        }

        // 右下角圆弧
        for i in 0..<pointsPerArc {
            let theta = -.pi / 2 + CGFloat(i) / CGFloat(pointsPerArc) * (.pi / 2)

            points.append(
                .init(
                    x: corners[1].x + cornerRadius * cos(theta),
                    y: corners[1].y + cornerRadius * sin(theta)
                )
            )
        }

        // 右边
        for i in 0..<pointsPerSection[1] {
            let t = CGFloat(i) / CGFloat(pointsPerSection[1])

            points.append(
                .init(
                    x: maxX,
                    y: minY + cornerRadius + t * (height - 2 * cornerRadius)
                )
            )
        }

        // 右上角圆弧
        for i in 0..<pointsPerArc {
            let theta = 0 + CGFloat(i) / CGFloat(pointsPerArc) * (.pi / 2)

            points.append(
                .init(
                    x: corners[2].x + cornerRadius * cos(theta),
                    y: corners[2].y + cornerRadius * sin(theta)
                )
            )
        }

        // 顶边
        for i in 0..<pointsPerSection[2] {
            let t = CGFloat(i) / CGFloat(pointsPerSection[2])

            points.append(
                .init(
                    x: maxX - cornerRadius - t * (width - 2 * cornerRadius),
                    y: maxY
                )
            )
        }

        // 左上角圆弧
        for i in 0..<pointsPerArc {
            let theta = .pi / 2 + CGFloat(i) / CGFloat(pointsPerArc) * (.pi / 2)

            points.append(
                .init(
                    x: corners[3].x + cornerRadius * cos(theta),
                    y: corners[3].y + cornerRadius * sin(theta)
                )
            )
        }

        // 左边
        for i in 0..<pointsPerSection[3] {
            let t = CGFloat(i) / CGFloat(pointsPerSection[3])

            points.append(
                .init(
                    x: minX,
                    y: maxY - cornerRadius - t * (height - 2 * cornerRadius)
                )
            )
        }

        // 左下角圆弧
        for i in 0..<pointsPerArc {
            let theta = .pi + CGFloat(i) / CGFloat(pointsPerArc) * (.pi / 2)

            points.append(
                .init(
                    x: corners[0].x + cornerRadius * cos(theta),
                    y: corners[0].y + cornerRadius * sin(theta)
                )
            )
        }

        return points
    }
}

private struct DemoView: View {
    @State private var points: [CGPoint] = [.zero]

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.periodic(from: .now, by: 0.02)) { timeline in
                Capsule()
                    .glowBorder(fill: .palette)
                    .shiny(at: point(for: timeline.date))
            }
            .onAppear {
                points = proxy.frame(in: .local).roundedRectPoints(
                    cornerRadius: proxy.size.height / 2,
                    proposedNumberOfPoints: 30
                )
            }
        }
    }

    private func point(for date: Date) -> CGPoint {
        points[Int(date.timeIntervalSinceReferenceDate * 10) % points.count]
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        DemoView()
            .frame(
                width: 240,
                height: 100
            )
    }
}
