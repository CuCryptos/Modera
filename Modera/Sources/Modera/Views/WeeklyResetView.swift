import SwiftUI

struct WeeklyResetView: View {
    @ObservedObject var viewModel: BalanceViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var reflectTogether = false
    @State private var steadyNote = ""
    @State private var shiftNote = ""
    @State private var displayRatio: Double
    @State private var isResetting = false

    init(viewModel: BalanceViewModel) {
        self.viewModel = viewModel
        _displayRatio = State(initialValue: viewModel.balanceRatio)
    }

    var body: some View {
        ZStack {
            ModeraStyle.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Text("Week complete")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    BalanceRingView(balanceRatio: displayRatio, size: 190, lineWidth: 18)

                    Text("Balance Score: \(viewModel.balanceScore)")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    Text(viewModel.weeklyRecapLine)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)

                    Button {
                        withAnimation(ModeraMotion.micro) {
                            reflectTogether.toggle()
                        }
                    } label: {
                        Text("Reflect together")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    if reflectTogether {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("What felt steady this week?")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.9))
                                TextField("Optional note", text: $steadyNote)
                                    .textFieldStyle(.roundedBorder)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("What could shift next week?")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.9))
                                TextField("Optional note", text: $shiftNote)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Button {
                        beginWeek()
                    } label: {
                        Text(isResetting ? "Resetting..." : "Begin Week")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(ModeraStyle.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isResetting)
                }
                .padding(24)
            }
        }
        .navigationTitle("Weekly Reset")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func beginWeek() {
        guard !isResetting else { return }
        isResetting = true

        withAnimation(ModeraMotion.reset) {
            displayRatio = 0.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            viewModel.beginNewWeek()
            steadyNote = ""
            shiftNote = ""
            withAnimation(ModeraMotion.micro) {
                reflectTogether = false
            }
            isResetting = false
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        WeeklyResetView(viewModel: BalanceViewModel())
    }
}
