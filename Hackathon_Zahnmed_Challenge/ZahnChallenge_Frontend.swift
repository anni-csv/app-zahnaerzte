//  ZahnChallenge_Frontend.swift
//  Hackathon_Zahnmed_Challenge
//
//  Zuständigkeit: Alle SwiftUI Views

import SwiftUI
import PhotosUI

// MARK: - ENTRY POINT
struct ContentView: View {
    @StateObject private var appVM = AppViewModel()
    
    var body: some View {
        if appVM.showCaseSelection {
            CaseSelectionView(appVM: appVM)
        } else {
            ChallengeView(appVM: appVM)
        }
    }
}

// MARK: - FALL-AUSWAHL
struct CaseSelectionView: View {
    @ObservedObject var appVM: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F5F5F5").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "tooth.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "2D6A4F"))
                        Text("ZahnChallenge")
                            .font(.largeTitle).bold()
                        Text("Wähle einen Fall")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Fall-Karten
                    CaseCard(dentalCase: appVM.fall1) {
                        appVM.selectCase(appVM.fall1)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct CaseCard: View {
    let dentalCase: DentalCase
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dentalCase.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(dentalCase.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                    Text("\(dentalCase.steps.count) Schritte")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [Color(hex: "2D6A4F"), Color(hex: "52B788")],
                        startPoint: .leading, endPoint: .trailing
                    ))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - HAUPT-CHALLENGE VIEW
struct ChallengeView: View {
    @ObservedObject var appVM: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F5F5F5").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Bar
                    ProgressView(value: appVM.progressValue)
                        .tint(Color(hex: "2D6A4F"))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Schritt-Anzeige
                    if let step = appVM.currentStep {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Schritt-Header
                                StepHeaderView(
                                    stepNumber: step.id,
                                    total: appVM.selectedCase?.steps.count ?? 0,
                                    title: step.title
                                )
                                
                                // Inhalt
                                if step.isUploadStep {
                                    // SCHRITT 8: Upload + Gemini-Auswertung
                                    UploadEvaluationView(
                                        geminiVM: appVM.geminiViewModel,
                                        prompt: appVM.selectedCase?.geminiPrompt ?? ""
                                    )
                                } else {
                                    // Normaler Schritt
                                    StepContentCard(description: step.description)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Navigation
                    NavigationButtonsView(appVM: appVM)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Fälle") {
                        appVM.returnToSelection()
                    }
                    .foregroundColor(Color(hex: "2D6A4F"))
                }
                ToolbarItem(placement: .principal) {
                    Text(appVM.selectedCase?.title ?? "")
                        .font(.headline)
                }
            }
        }
    }
}

// MARK: - SCHRITT-HEADER
struct StepHeaderView: View {
    let stepNumber: Int
    let total: Int
    let title: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(hex: "2D6A4F"))
                    .frame(width: 44, height: 44)
                Text("\(stepNumber)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Schritt \(stepNumber) von \(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.title3).bold()
            }
            Spacer()
        }
    }
}

// MARK: - SCHRITT-INHALT (normale Schritte)
struct StepContentCard: View {
    let description: String
    
    var body: some View {
        Text(description)
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
    }
}

// MARK: - UPLOAD & AUSWERTUNG (Schritt 8)
struct UploadEvaluationView: View {
    @ObservedObject var geminiVM: GeminiViewModel
    let prompt: String
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Beschreibung
            Text("Lade ein Foto deiner Arbeit hoch.\nDie KI bewertet Position und Splint-Anlage.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Foto-Vorschau oder Picker
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "E8F5E9"))
                        .frame(height: 220)
                    
                    if let image = geminiVM.uploadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "2D6A4F"))
                            Text("Foto auswählen")
                                .font(.headline)
                                .foregroundColor(Color(hex: "2D6A4F"))
                            Text("Tippe zum Hochladen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            geminiVM.uploadedImage = uiImage
                            geminiVM.feedbackText = nil
                            geminiVM.showFeedback = false
                            geminiVM.errorMessage = nil
                        }
                    }
                }
            }
            
            // Auswertungs-Button
            Button(action: {
                Task {
                    await geminiVM.evaluate(prompt: prompt)
                }
            }) {
                HStack {
                    if geminiVM.isEvaluating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "brain.head.profile")
                    }
                    Text(geminiVM.isEvaluating ? "KI wertet aus…" : "KI-Auswertung starten")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(geminiVM.uploadedImage == nil
                              ? Color.gray.opacity(0.4)
                              : Color(hex: "2D6A4F"))
                )
                .foregroundColor(.white)
            }
            .disabled(geminiVM.uploadedImage == nil || geminiVM.isEvaluating)
            
            // Fehler-Hinweis (Demo-Modus)
            if let errMsg = geminiVM.errorMessage {
                Text(errMsg)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal)
            }
            
            // Feedback-Anzeige
            if geminiVM.showFeedback, let feedback = geminiVM.feedbackText {
                FeedbackCard(feedback: feedback)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - FEEDBACK-KARTE
struct FeedbackCard: View {
    let feedback: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Color(hex: "2D6A4F"))
                Text("KI-Auswertung")
                    .font(.headline)
                    .foregroundColor(Color(hex: "2D6A4F"))
            }
            Divider()
            Text(feedback)
                .font(.body)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "E8F5E9"))
        )
    }
}

// MARK: - NAVIGATIONS-BUTTONS
struct NavigationButtonsView: View {
    @ObservedObject var appVM: AppViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Zurück
            if appVM.currentStepIndex > 0 {
                Button(action: appVM.previousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "2D6A4F"), lineWidth: 1.5)
                    )
                    .foregroundColor(Color(hex: "2D6A4F"))
                }
            }
            
            // Weiter / Abschluss
            Button(action: appVM.isLastStep ? appVM.returnToSelection : appVM.nextStep) {
                HStack {
                    Text(appVM.isLastStep ? "Abschließen ✓" : "Weiter")
                    if !appVM.isLastStep {
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "2D6A4F"))
                )
                .foregroundColor(.white)
            }
        }
        .padding()
        .background(.white)
        .shadow(color: .black.opacity(0.05), radius: 4, y: -2)
    }
}

// MARK: - HEX COLOR EXTENSION
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
