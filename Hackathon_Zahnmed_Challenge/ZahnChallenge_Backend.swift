//  ZahnChallenge_Backend.swift
//  Hackathon_Zahnmed_Challenge

import Foundation
import Combine
import SwiftUI

struct ChallengeStep: Identifiable {
    let id: Int
    let title: String
    let description: String
    let isUploadStep: Bool

    init(id: Int, title: String, description: String, isUploadStep: Bool = false) {
        self.id = id; self.title = title
        self.description = description; self.isUploadStep = isUploadStep
    }
}

struct DentalCase: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let steps: [ChallengeStep]
    let geminiPrompt: String
}

class AppViewModel: ObservableObject {
    // ✅ NEU: Screen-State statt NavigationStack
    @Published var currentScreen: AppScreen = .selection
    @Published var selectedCase: DentalCase? = nil
    @Published var currentStepIndex: Int = 0

    let geminiViewModel = GeminiViewModel()

    let fall1 = DentalCase(
        id: 1,
        title: "Fall 1: Avulsion Zahn 11",
        subtitle: "Repositionierung & Titan-Trauma-Splint",
        steps: [
            ChallengeStep(id: 1,  title: "Anamnese",
                description: "Patient, 24 J., Fahrradsturz vor 30 min. Zahn 11 avulsiert, in Milch aufbewahrt. Keine Allergien, keine Medikamente."),
            ChallengeStep(id: 2,  title: "Befund",
                description: "Leere Alveole regio 11, Randbezirke intakt. Kein Knochendefekt tastbar. Avulsierter Zahn: Wurzel vollständig, Schmelzfraktur inzisal."),
            ChallengeStep(id: 3,  title: "Diagnose",
                description: "Avulsion 11. Extraalveoläre Lagerungszeit: 30 min (feuchtes Medium). Prognose gut bei sofortiger Replantation."),
            ChallengeStep(id: 4,  title: "Aufklärung",
                description: "Patient über Prognose, Vorgehen, Risiken (Ankylose, Resorption) und Nachsorge aufgeklärt. Einverständnis eingeholt."),
            ChallengeStep(id: 5,  title: "Anästhesie",
                description: "Leitungsanästhesie N. alveolaris superior anterior + bukkale Infiltration. Warten auf Wirkungseintritt."),
            ChallengeStep(id: 6,  title: "Alveole vorbereiten",
                description: "Alveole mit steriler NaCl-Lösung spülen. Koagulum vorsichtig entfernen. Zahn in NaCl-Lösung lagern bis zur Replantation."),
            ChallengeStep(id: 7,  title: "Replantation",
                description: "Zahn 11 unter leichtem Druck in die Alveole reponieren. Achse und Höhe zur Kontrolle mit Nachbarzähnen vergleichen. Okklusionskontrolle."),
            ChallengeStep(id: 8,  title: "Foto & KI-Auswertung",
                description: "Tippe auf 'Zur KI-Auswertung' um ein Foto hochzuladen und deine Arbeit bewerten zu lassen.",
                isUploadStep: true),
            ChallengeStep(id: 9,  title: "Nachsorge",
                description: "Schiene für 2 Wochen belassen. Antibiotika (Amoxicillin 500mg 3x/Tag, 7 Tage). Weiches Essen. Recall in 1 Woche."),
            ChallengeStep(id: 10, title: "Abschluss",
                description: "Dokumentation vollständig. Fall erfolgreich abgeschlossen! Weiterer Recall: 1, 3, 6 Monate + jährlich.")
        ],
        geminiPrompt: GeminiPrompts.fall1_upload
    )

    func selectCase(_ dentalCase: DentalCase) {
        selectedCase = dentalCase
        currentStepIndex = 0
        currentScreen = .steps
        geminiViewModel.reset()
    }

    func nextStep() {
        guard let c = selectedCase, currentStepIndex < c.steps.count - 1 else { return }
        currentStepIndex += 1
    }

    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
    }

    func returnToSelection() {
        currentScreen = .selection
        selectedCase = nil
        currentStepIndex = 0
        geminiViewModel.reset()
    }

    var currentStep: ChallengeStep? {
        guard let c = selectedCase, currentStepIndex < c.steps.count else { return nil }
        return c.steps[currentStepIndex]
    }

    var isLastStep: Bool {
        guard let c = selectedCase else { return false }
        return currentStepIndex == c.steps.count - 1
    }

    var progressValue: Double {
        guard let c = selectedCase, c.steps.count > 1 else { return 0 }
        return Double(currentStepIndex) / Double(c.steps.count - 1)
    }

    // showCaseSelection nicht mehr nötig – wird durch currentScreen ersetzt
    var showCaseSelection: Bool { currentScreen == .selection }
}
