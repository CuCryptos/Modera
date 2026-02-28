import Combine
import Foundation

enum EffortSide: String, CaseIterable, Identifiable {
    case left
    case right

    var id: String { rawValue }

    var label: String {
        switch self {
        case .left:
            return "Left"
        case .right:
            return "Right"
        }
    }
}

struct ImpactProjection {
    let leftEffort: Double
    let rightEffort: Double

    var balanceRatio: Double {
        let total = leftEffort + rightEffort
        guard total > 0 else { return 0.5 }
        return leftEffort / total
    }
}

@MainActor
final class BalanceViewModel: ObservableObject {
    @Published var leftEffort: Double = 55
    @Published var rightEffort: Double = 45
    @Published var selectedCompletionSide: EffortSide = .left

    private let impactIncrement: Double = 4
    private let recalibrationFactor: Double = 0.07

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

    var effortSplitLine: String {
        "Effort split: \(Int(leftEffort.rounded())) / \(Int(rightEffort.rounded()))"
    }

    var distanceFromEvenLine: String {
        let distance = Int(abs(balanceRatio - 0.5) * 200)
        return "Distance from even: \(distance)%"
    }

    func projectedTaskImpact(by side: EffortSide) -> ImpactProjection {
        var projectedLeft = leftEffort
        var projectedRight = rightEffort

        switch side {
        case .left:
            projectedLeft += impactIncrement
        case .right:
            projectedRight += impactIncrement
        }

        let total = projectedLeft + projectedRight
        guard total > 0 else {
            return ImpactProjection(leftEffort: 50, rightEffort: 50)
        }

        projectedLeft = projectedLeft / total * 100
        projectedRight = 100 - projectedLeft

        // Keep growth directional while softly damping drift away from center.
        projectedLeft += (50 - projectedLeft) * recalibrationFactor
        projectedRight = 100 - projectedLeft

        return ImpactProjection(leftEffort: projectedLeft, rightEffort: projectedRight)
    }

    func applyTaskImpact(by side: EffortSide) -> ImpactProjection {
        let projection = projectedTaskImpact(by: side)
        leftEffort = projection.leftEffort
        rightEffort = projection.rightEffort
        return projection
    }

    func beginNewWeek() {
        leftEffort = 50
        rightEffort = 50
    }
}
