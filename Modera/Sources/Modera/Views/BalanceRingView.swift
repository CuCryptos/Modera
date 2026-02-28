import SwiftUI

struct BalanceRingView: View {
    var balanceRatio: Double
    var size: CGFloat = 260
    var lineWidth: CGFloat = 22
    var pulseOpacity: Double = 0

    private var clampedRatio: Double {
        min(max(balanceRatio, 0), 1)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: size - lineWidth - 14)
                .blur(radius: 0.25)

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedRatio)
                .stroke(
                    ModeraStyle.ringPrimary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: clampedRatio, to: 1)
                .stroke(
                    ModeraStyle.ringSecondary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .stroke(ModeraStyle.recognition.opacity(pulseOpacity), lineWidth: 6)
                .scaleEffect(1.06)
                .blur(radius: 2)
        }
        .frame(width: size, height: size)
        .animation(ModeraMotion.settle, value: clampedRatio)
        .animation(ModeraMotion.recognitionFade, value: pulseOpacity)
    }
}

#Preview {
    ZStack {
        ModeraStyle.background.ignoresSafeArea()
        BalanceRingView(balanceRatio: 0.55, pulseOpacity: 0.4)
    }
}
