import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BalanceViewModel()

    var body: some View {
        NavigationStack {
            HomeBalanceView(viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
