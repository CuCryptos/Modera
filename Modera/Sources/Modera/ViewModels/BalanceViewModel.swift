import Combine
import Foundation

@MainActor
final class BalanceViewModel: ObservableObject {
    @Published var leftEffort: Double = 55
    @Published var rightEffort: Double = 45

    var balanceRatio: Double {
        let total = leftEffort + rightEffort
        guard total > 0 else { return 0.5 }
        return leftEffort / total
    }

    var balanceScore: Int {
        let imbalance = abs(leftEffort - rightEffort)
        let normalized = max(0, 100 - Int(imbalance * 2))
        return normalized
    }

    var descriptor: String {
        let diff = abs(leftEffort - rightEffort)
        switch diff {
        case 0...4:
            return "Steady"
        case 4.01...12:
            return "Shifting"
        default:
            return "Rebalancing"
        }
    }

    var weeklyRecapLine: String {
        "Small, consistent adjustments kept your week centered."
    }

    func applyTaskImpact() {
        let targetLeft = max(50, leftEffort - 3)
        let targetRight = min(50, rightEffort + 3)
        leftEffort = targetLeft
        rightEffort = targetRight
    }

    func beginNewWeek() {
        leftEffort = 50
        rightEffort = 50
    }
}
