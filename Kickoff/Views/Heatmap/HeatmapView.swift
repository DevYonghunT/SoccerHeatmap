import SwiftUI

enum HeatmapMode {
    case position
    case speed
}

struct HeatmapView: View {
    let points: [LocationPoint]
    var mode: HeatmapMode = .position
    var showFieldLines: Bool = true

    private static let gridX = 20
    private static let gridY = 13

    var body: some View {
        Canvas { context, size in
            // 1. Draw field background
            if showFieldLines {
                drawField(context: context, size: size)
            }

            // 2. Draw heatmap
            let grid = computeSmoothedGrid()
            guard !grid.smoothed.isEmpty, grid.maxValue > 0 else { return }

            let cellW = size.width / CGFloat(Self.gridX)
            let cellH = size.height / CGFloat(Self.gridY)

            for y in 0..<Self.gridY {
                for x in 0..<Self.gridX {
                    let intensity = grid.smoothed[y][x] / grid.maxValue
                    guard intensity > 0.05 else { continue }

                    let color = heatColor(intensity: intensity)
                    let center = CGPoint(
                        x: (CGFloat(x) + 0.5) * cellW,
                        y: (CGFloat(y) + 0.5) * cellH
                    )
                    let radius = cellW * 1.2

                    context.opacity = min(intensity, 0.85)
                    context.fill(
                        Circle().path(in: CGRect(
                            x: center.x - radius,
                            y: center.y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )),
                        with: .color(color)
                    )
                    // Apply a blur effect by drawing multiple circles
                    context.opacity = min(intensity * 0.5, 0.4)
                    let outerRadius = cellW * 1.8
                    context.fill(
                        Circle().path(in: CGRect(
                            x: center.x - outerRadius,
                            y: center.y - outerRadius,
                            width: outerRadius * 2,
                            height: outerRadius * 2
                        )),
                        with: .color(color)
                    )
                }
            }
            context.opacity = 1.0
        }
        .aspectRatio(20.0 / 13.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Field Drawing

    private func drawField(context: GraphicsContext, size: CGSize) {
        let lineColor = Color.fieldLine.opacity(0.4)

        // Background
        context.fill(
            Rectangle().path(in: CGRect(origin: .zero, size: size)),
            with: .color(Color.fieldGreen)
        )

        // Outline
        context.stroke(
            Rectangle().path(in: CGRect(origin: .zero, size: size)),
            with: .color(lineColor),
            lineWidth: 1
        )

        // Center line
        let centerX = size.width / 2
        context.stroke(
            Path { p in
                p.move(to: CGPoint(x: centerX, y: 0))
                p.addLine(to: CGPoint(x: centerX, y: size.height))
            },
            with: .color(lineColor),
            lineWidth: 1
        )

        // Center circle
        let circleRadius = size.height * 0.18
        context.stroke(
            Circle().path(in: CGRect(
                x: centerX - circleRadius,
                y: size.height / 2 - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )),
            with: .color(lineColor),
            lineWidth: 1
        )

        // Center dot
        context.fill(
            Circle().path(in: CGRect(
                x: centerX - 3,
                y: size.height / 2 - 3,
                width: 6,
                height: 6
            )),
            with: .color(lineColor)
        )

        // Penalty areas
        let penW = size.width * 0.15
        let penH = size.height * 0.44
        let penY = (size.height - penH) / 2

        context.stroke(
            Rectangle().path(in: CGRect(x: 0, y: penY, width: penW, height: penH)),
            with: .color(lineColor),
            lineWidth: 1
        )
        context.stroke(
            Rectangle().path(in: CGRect(x: size.width - penW, y: penY, width: penW, height: penH)),
            with: .color(lineColor),
            lineWidth: 1
        )

        // Goal areas
        let goalW = size.width * 0.06
        let goalH = size.height * 0.22
        let goalY = (size.height - goalH) / 2

        context.stroke(
            Rectangle().path(in: CGRect(x: 0, y: goalY, width: goalW, height: goalH)),
            with: .color(lineColor),
            lineWidth: 1
        )
        context.stroke(
            Rectangle().path(in: CGRect(x: size.width - goalW, y: goalY, width: goalW, height: goalH)),
            with: .color(lineColor),
            lineWidth: 1
        )
    }

    // MARK: - Grid Computation

    private struct GridResult {
        let smoothed: [[Double]]
        let maxValue: Double
    }

    private func computeSmoothedGrid() -> GridResult {
        guard !points.isEmpty else {
            return GridResult(smoothed: [], maxValue: 0)
        }

        var grid = Array(repeating: Array(repeating: 0.0, count: Self.gridX), count: Self.gridY)

        for point in points {
            let gx = min(max(Int(point.x * Double(Self.gridX - 1)), 0), Self.gridX - 1)
            let gy = min(max(Int(point.y * Double(Self.gridY - 1)), 0), Self.gridY - 1)
            let value: Double = mode == .speed ? point.speedKmh / 30.0 : 1.0
            grid[gy][gx] += value
        }

        // Gaussian smoothing
        let kernel: [[Double]] = [
            [0.05, 0.1, 0.05],
            [0.1,  0.4, 0.1],
            [0.05, 0.1, 0.05]
        ]

        var smoothed = Array(repeating: Array(repeating: 0.0, count: Self.gridX), count: Self.gridY)
        var maxVal: Double = 0

        for y in 0..<Self.gridY {
            for x in 0..<Self.gridX {
                var sum = 0.0
                for ky in -1...1 {
                    for kx in -1...1 {
                        let ny = min(max(y + ky, 0), Self.gridY - 1)
                        let nx = min(max(x + kx, 0), Self.gridX - 1)
                        sum += grid[ny][nx] * kernel[ky + 1][kx + 1]
                    }
                }
                smoothed[y][x] = sum
                if sum > maxVal { maxVal = sum }
            }
        }

        return GridResult(smoothed: smoothed, maxValue: maxVal)
    }

    // MARK: - Color

    private func heatColor(intensity: Double) -> Color {
        if mode == .speed {
            if intensity < 0.5 {
                return interpolateColor(from: .heatmapLow, to: .heatmapMid, t: intensity * 2)
            } else {
                return interpolateColor(from: .heatmapMid, to: .heatmapHigh, t: (intensity - 0.5) * 2)
            }
        } else {
            if intensity < 0.4 {
                return interpolateColor(from: .heatmapLow, to: .heatmapMid, t: intensity / 0.4)
            } else {
                return interpolateColor(from: .heatmapMid, to: .heatmapHigh, t: (intensity - 0.4) / 0.6)
            }
        }
    }

    private func interpolateColor(from: Color, to: Color, t: Double) -> Color {
        let t = min(max(t, 0), 1)
        // Use UIColor for component extraction
        let fromUI = UIColor(from)
        let toUI = UIColor(to)

        var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0

        fromUI.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        toUI.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)

        return Color(
            red: Double(fr + CGFloat(t) * (tr - fr)),
            green: Double(fg + CGFloat(t) * (tg - fg)),
            blue: Double(fb + CGFloat(t) * (tb - fb))
        )
    }
}
