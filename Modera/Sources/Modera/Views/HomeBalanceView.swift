import SwiftUI

struct HomeBalanceView: View {
    @ObservedObject var viewModel: BalanceViewModel

    var body: some View {
        ZStack {
            ModeraStyle.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 18)

                BalanceRingView(balanceRatio: viewModel.balanceRatio)

                VStack(spacing: 6) {
                    Text("Balance Score")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    Text("\(viewModel.balanceScore)")
                        .font(.system(size: 48, weight: .semibold, design: .default))
                        .foregroundStyle(.white)

                    Text(viewModel.descriptor)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))
                }

                NavigationLink {
                    TaskCompletionMomentView(viewModel: viewModel)
                } label: {
                    Text("Complete Sample Task")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(ModeraStyle.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                NavigationLink {
                    WeeklyResetView(viewModel: viewModel)
                } label: {
                    Text("Weekly Reset")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.76))
                        .padding(.vertical, 6)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Modera")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HomeBalanceView(viewModel: BalanceViewModel())
    }
}
