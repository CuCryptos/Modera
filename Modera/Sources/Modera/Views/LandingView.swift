import SwiftUI

struct LandingView: View {
    let onJoinEarlyAccess: () -> Void
    let onOpenPrototype: () -> Void

    var body: some View {
        ZStack {
            ModeraStyle.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    hero

                    section(
                        title: "The Real Problem",
                        lines: [
                            "Shared effort is hard to see.",
                            "Most households guess.",
                            "Guessing creates friction.",
                            "Modera replaces guesswork with visibility.",
                            "Not competition. Not blame. Just clarity."
                        ]
                    )

                    section(
                        title: "See Your Balance",
                        lines: [
                            "At a glance, see how effort distributes.",
                            "Small actions shift the balance.",
                            "Over time, patterns become clear.",
                            "When effort is visible, conversations change."
                        ]
                    )

                    section(
                        title: "A Weekly Reset Ritual",
                        lines: [
                            "Every week ends with a reset.",
                            "Reflect. Recognize. Recalibrate.",
                            "Then begin again.",
                            "Modera turns difficult conversations into structured reflection."
                        ]
                    )

                    section(
                        title: "Growth Over Time",
                        lines: [
                            "You won’t chase perfection.",
                            "You’ll build consistency.",
                            "You’ll recover from imbalance faster.",
                            "You’ll improve week by week.",
                            "That’s growth."
                        ]
                    )

                    section(
                        title: "What Modera Is Not",
                        lines: [
                            "Not a chore app.",
                            "Not a leaderboard.",
                            "Not a productivity tracker.",
                            "Modera is a framework for shared improvement."
                        ]
                    )

                    finalCTA
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
            }
        }
        .navigationTitle("Modera")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Modera")
                .font(.system(size: 44, weight: .semibold, design: .default))
                .foregroundStyle(.white)

            Text("Make effort visible.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.92))

            Text("A shared growth framework that helps households improve week by week.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.72))

            Button(action: onJoinEarlyAccess) {
                Text("Join the Early Access List")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(ModeraStyle.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var finalCTA: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Make effort visible.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("Start your shared balance.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.76))

            Button(action: onJoinEarlyAccess) {
                Text("Get Early Access")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(ModeraStyle.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(action: onOpenPrototype) {
                Text("Open Prototype")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 6)
    }

    private func section(title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.74))
            }
        }
    }
}

struct EarlyAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                ModeraStyle.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Early Access")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Drop your email and we’ll send launch updates.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.75))

                    TextField("name@email.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        dismiss()
                        onContinue()
                    } label: {
                        Text("Join + Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ModeraStyle.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        dismiss()
                    } label: {
                        Text("Not now")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(24)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        LandingView(onJoinEarlyAccess: {}, onOpenPrototype: {})
    }
}
