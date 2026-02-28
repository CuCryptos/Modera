import SwiftUI

enum ModeraStyle {
    static let background = Color(red: 0.08, green: 0.11, blue: 0.14)
    static let ringPrimary = Color(red: 0.33, green: 0.67, blue: 0.64)
    static let ringSecondary = Color(red: 0.23, green: 0.47, blue: 0.45)
    static let accent = Color(red: 0.32, green: 0.63, blue: 0.60)
    static let recognition = Color(red: 0.84, green: 0.72, blue: 0.45)
    static let recognitionText = Color(red: 0.88, green: 0.78, blue: 0.56)
}

enum ModeraMotion {
    static let settle = Animation.timingCurve(0.24, 0.08, 0.2, 1, duration: 0.95)
    static let recognitionReveal = Animation.easeInOut(duration: 0.36)
    static let recognitionFade = Animation.easeInOut(duration: 0.6)
    static let reset = Animation.timingCurve(0.24, 0.08, 0.2, 1, duration: 1.1)
    static let micro = Animation.easeInOut(duration: 0.3)
}
