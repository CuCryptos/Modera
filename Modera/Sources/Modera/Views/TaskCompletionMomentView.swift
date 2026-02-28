import SwiftUI

struct TaskCompletionMomentView: View {
    @ObservedObject var viewModel: BalanceViewModel

    @State private var displayRatio: Double
    @State private var pulseOpacity: Double = 0
    @State private var didRunSequence = false
    @State private var showImpactText = false

    init(viewModel: BalanceViewModel) {
        self.viewModel = viewModel
        _displayRatio = State(initialValue: viewModel.balanceRatio)
    }

    var body: some View {
        ZStack {
            ModeraStyle.background.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 24)

                BalanceRingView(
                    balanceRatio: displayRatio,
                    pulseOpacity: pulseOpacity
                )

                if showImpactText {
                    Text("Impact recorded")
                        .font(.subheadline)
                        .foregroundStyle(ModeraStyle.recognitionText)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Task Complete")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            runSequenceIfNeeded()
        }
    }

    private func runSequenceIfNeeded() {
        guard !didRunSequence else { return }
        didRunSequence = true

        let adjustedLeft = max(50, viewModel.leftEffort - 3)
        let adjustedRight = min(50, viewModel.rightEffort + 3)
        let targetRatio = adjustedLeft / (adjustedLeft + adjustedRight)

        withAnimation(ModeraMotion.settle) {
            displayRatio = targetRatio
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(ModeraMotion.recognitionReveal) {
                showImpactText = true
                pulseOpacity = 0.58
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                withAnimation(ModeraMotion.recognitionFade) {
                    pulseOpacity = 0.2
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                withAnimation(ModeraMotion.recognitionFade) {
                    pulseOpacity = 0
                }
            }

            viewModel.applyTaskImpact()
        }
    }
}

#Preview {
    NavigationStack {
        TaskCompletionMomentView(viewModel: BalanceViewModel())
    }
}
