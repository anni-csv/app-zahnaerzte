import SwiftUI
import Combine
import UniformTypeIdentifiers

// MARK: - DATA MODEL
struct PatientCase: Identifiable {
    let id = UUID()
    let sfSymbol: String
    let category: String
    let title: String
    let difficulty: Int
    let difficultyLabel: String
    let gradientStart: Color
    let gradientEnd: Color
    let starColor: Color
    let badge: String?
    let badgeBG: Color?
    let badgeText: Color?
    let progress: Double
    let totalSteps: Int
}

// MARK: - APP STATE
class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedCategory: String = "Notfallbehandlung"
    @Published var showAvatarSheet: Bool = false
    @Published var userScore: Int = UserDefaults.standard.integer(forKey: "userScore")
    @Published var fall1Completed: Bool = UserDefaults.standard.bool(forKey: "fall1_completed")
    @Published var fall2Completed: Bool = UserDefaults.standard.bool(forKey: "fall2_completed")

    let categories = ["Notfallbehandlung", "Endodontie", "Parodontologie", "Kieferchirurgie"]

    let cases: [PatientCase] = [
        PatientCase(
            sfSymbol: "cross.case.fill",
            category: "NOTFALLBEHANDLUNG",
            title: "Volksfest-Unfall",
            difficulty: 2,
            difficultyLabel: "Mittel",
            gradientStart: Color(hex: "FFD6A5"),
            gradientEnd: Color(hex: "FFEFCF"),
            starColor: Color(hex: "F59E0B"),
            badge: nil, badgeBG: nil, badgeText: nil,
            progress: 0.0, totalSteps: 6
        ),
        PatientCase(
            sfSymbol: "waveform.path.ecg",
            category: "ENDODONTIE",
            title: "Schmerzen in der Nacht",
            difficulty: 3,
            difficultyLabel: "Schwer",
            gradientStart: Color(hex: "C9F0FF"),
            gradientEnd: Color(hex: "A5D8FF"),
            starColor: Color(hex: "EF4444"),
            badge: "In Bearbeitung",
            badgeBG: Color(hex: "FFEDD5"),
            badgeText: Color(hex: "C2410C"),
            progress: 0.3, totalSteps: 8
        ),
        PatientCase(
            sfSymbol: "magnifyingglass.circle.fill",
            category: "PARODONTOLOGIE",
            title: "Parodontitis-Erstuntersuchung",
            difficulty: 1,
            difficultyLabel: "Leicht",
            gradientStart: Color(hex: "B5EAD7"),
            gradientEnd: Color(hex: "CAFFBF"),
            starColor: Color(hex: "10B981"),
            badge: "Neu",
            badgeBG: Color(hex: "DBEAFE"),
            badgeText: Color(hex: "1D4ED8"),
            progress: 0.0, totalSteps: 8
        )
    ]

    func addPoints(_ points: Int) {
        userScore += points
        UserDefaults.standard.set(userScore, forKey: "userScore")
    }

    func markCompleted(caseIndex: Int) {
        if caseIndex == 0 {
            fall1Completed = true
            UserDefaults.standard.set(true, forKey: "fall1_completed")
        }
        if caseIndex == 1 {
            fall2Completed = true
            UserDefaults.standard.set(true, forKey: "fall2_completed")
        }
    }
}

// MARK: - COLOR EXTENSION
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
