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

                    Text(viewModel.effortSplitLine)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.66))

                    Text(viewModel.distanceFromEvenLine)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.66))
                }

                NavigationLink {
                    TaskCompletionMomentView(
                        viewModel: viewModel,
                        completedBy: viewModel.selectedCompletionSide,
                        task: viewModel.selectedTask
                    )
                } label: {
                    Text("Complete \(viewModel.selectedTask.title)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(ModeraStyle.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Picker("Task Type", selection: $viewModel.selectedTask) {
                    ForEach(TaskTemplate.allCases) { task in
                        Text(task.title).tag(task)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white.opacity(0.85))

                Picker("Completed by", selection: $viewModel.selectedCompletionSide) {
                    ForEach(EffortSide.allCases) { side in
                        Text(side.label).tag(side)
                    }
                }
                .pickerStyle(.segmented)

                if !viewModel.recentHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This week")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.8))

                        ForEach(viewModel.recentHistory) { event in
                            HStack {
                                Text("\(event.side.label) · \(event.task.title)")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.78))
                                Spacer()
                                Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

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
