import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BalanceViewModel()
    @State private var showPrototype = false
    @State private var showEarlyAccessSheet = false

    var body: some View {
        NavigationStack {
            if showPrototype {
                HomeBalanceView(viewModel: viewModel)
            } else {
                LandingView(
                    onJoinEarlyAccess: { showEarlyAccessSheet = true },
                    onOpenPrototype: {
                        withAnimation(ModeraMotion.micro) {
                            showPrototype = true
                        }
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showEarlyAccessSheet) {
            EarlyAccessSheet {
                withAnimation(ModeraMotion.micro) {
                    showPrototype = true
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
}
