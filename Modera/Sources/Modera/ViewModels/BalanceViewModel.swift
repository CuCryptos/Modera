import Combine
import Foundation

enum EffortSide: String, CaseIterable, Identifiable, Codable {
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

enum TaskTemplate: String, CaseIterable, Identifiable, Codable {
    case checkIn
    case planning
    case household
    case care

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checkIn:
            return "Daily Check-in"
        case .planning:
            return "Plan the Week"
        case .household:
            return "Shared Household Task"
        case .care:
            return "Partner Support Moment"
        }
    }

    var impactWeight: Double {
        switch self {
        case .checkIn:
            return 2.8
        case .planning:
            return 3.6
        case .household:
            return 3.2
        case .care:
            return 4.0
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

struct TaskEvent: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let side: EffortSide
    let task: TaskTemplate
    let ratioAfter: Double
    let scoreAfter: Int
}

struct WeeklySnapshot: Identifiable, Codable {
    let id: UUID
    let weekStart: Date
    let score: Int
    let steadyNote: String
    let shiftNote: String
}

private struct PersistedState: Codable {
    var leftEffort: Double
    var rightEffort: Double
    var selectedCompletionSide: EffortSide
    var selectedTask: TaskTemplate
    var lastWeekScore: Int?
    var currentWeekSteadyNote: String
    var currentWeekShiftNote: String
    var currentWeekStartedAt: Date
    var taskHistory: [TaskEvent]
    var weeklySnapshots: [WeeklySnapshot]
}

@MainActor
final class BalanceViewModel: ObservableObject {
    @Published var leftEffort: Double = 55
    @Published var rightEffort: Double = 45
    @Published var selectedCompletionSide: EffortSide = .left
    @Published var selectedTask: TaskTemplate = .checkIn
    @Published var currentWeekSteadyNote: String = ""
    @Published var currentWeekShiftNote: String = ""
    @Published private(set) var currentWeekStartedAt: Date = Date()
    @Published private(set) var lastWeekScore: Int? = 76
    @Published private(set) var taskHistory: [TaskEvent] = []
    @Published private(set) var weeklySnapshots: [WeeklySnapshot] = []

    private let recalibrationFactor: Double = 0.07
    private let stateStoreKey = "modera_state_v1"
    private var cancellables: Set<AnyCancellable> = []

    init() {
        loadState()
        setupAutosave()
    }

    var balanceRatio: Double {
        let total = leftEffort + rightEffort
        guard total > 0 else { return 0.5 }
        return leftEffort / total
    }

    var balanceScore: Int {
        score(forLeftEffort: leftEffort, rightEffort: rightEffort)
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
        let count = thisWeekHistory.count
        if count == 0 {
            return "No entries yet this week. Small moments still count."
        }
        return "\(count) shared moments were recorded this week."
    }

    var weekToWeekDeltaLine: String? {
        guard let lastWeekScore else { return nil }
        let delta = balanceScore - lastWeekScore

        if delta >= 3 {
            return "More stable than last week (+\(delta))"
        }
        if delta > 0 {
            return "+\(delta) vs last week"
        }
        if delta == 0 {
            return "About the same as last week"
        }
        if delta <= -3 {
            return "Less stable than last week (\(delta))"
        }
        return "\(delta) vs last week"
    }

    var effortSplitLine: String {
        "Effort split: \(Int(leftEffort.rounded())) / \(Int(rightEffort.rounded()))"
    }

    var distanceFromEvenLine: String {
        let distance = Int(abs(balanceRatio - 0.5) * 200)
        return "Distance from even: \(distance)%"
    }

    var thisWeekHistory: [TaskEvent] {
        return taskHistory
            .filter { $0.timestamp >= currentWeekStartedAt }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var recentHistory: [TaskEvent] {
        Array(thisWeekHistory.prefix(4))
    }

    func projectedTaskImpact(by side: EffortSide, task: TaskTemplate) -> ImpactProjection {
        var projectedLeft = leftEffort
        var projectedRight = rightEffort

        switch side {
        case .left:
            projectedLeft += task.impactWeight
        case .right:
            projectedRight += task.impactWeight
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

    func applyTaskImpact(by side: EffortSide, task: TaskTemplate) -> ImpactProjection {
        let projection = projectedTaskImpact(by: side, task: task)
        leftEffort = projection.leftEffort
        rightEffort = projection.rightEffort

        let event = TaskEvent(
            id: UUID(),
            timestamp: Date(),
            side: side,
            task: task,
            ratioAfter: projection.balanceRatio,
            scoreAfter: balanceScore
        )
        taskHistory.append(event)

        return projection
    }

    func beginNewWeek() {
        let snapshot = WeeklySnapshot(
            id: UUID(),
            weekStart: currentWeekStartedAt,
            score: balanceScore,
            steadyNote: currentWeekSteadyNote,
            shiftNote: currentWeekShiftNote
        )
        weeklySnapshots.append(snapshot)
        if weeklySnapshots.count > 52 {
            weeklySnapshots.removeFirst(weeklySnapshots.count - 52)
        }

        lastWeekScore = balanceScore
        currentWeekSteadyNote = ""
        currentWeekShiftNote = ""
        currentWeekStartedAt = Date()
        leftEffort = 50
        rightEffort = 50
    }

    private func score(forLeftEffort left: Double, rightEffort right: Double) -> Int {
        let imbalance = abs(left - right)
        return max(0, 100 - Int(imbalance * 2))
    }

    private func setupAutosave() {
        $leftEffort.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $rightEffort.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $selectedCompletionSide.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $selectedTask.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $lastWeekScore.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $currentWeekSteadyNote.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $currentWeekShiftNote.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $currentWeekStartedAt.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $taskHistory.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
        $weeklySnapshots.dropFirst().sink { [weak self] _ in self?.persistState() }.store(in: &cancellables)
    }

    private func persistState() {
        let state = PersistedState(
            leftEffort: leftEffort,
            rightEffort: rightEffort,
            selectedCompletionSide: selectedCompletionSide,
            selectedTask: selectedTask,
            lastWeekScore: lastWeekScore,
            currentWeekSteadyNote: currentWeekSteadyNote,
            currentWeekShiftNote: currentWeekShiftNote,
            currentWeekStartedAt: currentWeekStartedAt,
            taskHistory: taskHistory,
            weeklySnapshots: weeklySnapshots
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(state)
            UserDefaults.standard.set(data, forKey: stateStoreKey)
        } catch {
            assertionFailure("Failed to persist state: \(error)")
        }
    }

    private func loadState() {
        guard let data = UserDefaults.standard.data(forKey: stateStoreKey) else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let state = try decoder.decode(PersistedState.self, from: data)
            leftEffort = state.leftEffort
            rightEffort = state.rightEffort
            selectedCompletionSide = state.selectedCompletionSide
            selectedTask = state.selectedTask
            lastWeekScore = state.lastWeekScore
            currentWeekSteadyNote = state.currentWeekSteadyNote
            currentWeekShiftNote = state.currentWeekShiftNote
            currentWeekStartedAt = state.currentWeekStartedAt
            taskHistory = state.taskHistory
            weeklySnapshots = state.weeklySnapshots
        } catch {
            UserDefaults.standard.removeObject(forKey: stateStoreKey)
        }
    }
}
