//  ZahnChallenge_Frontend.swift
//  Hackathon_Zahnmed_Challenge

import SwiftUI
import PhotosUI

// MARK: - ENTRY POINT
struct ContentView: View {
    @StateObject private var appVM = AppViewModel()

    var body: some View {
        switch appVM.currentScreen {
        case .selection:
            CaseSelectionView(appVM: appVM)
        case .steps:
            ChallengeStepsView(appVM: appVM)
        case .gemini:
            GeminiScreenView(appVM: appVM)
        }
    }
}

// MARK: - SCREEN ENUM (kein NavigationStack nötig)
enum AppScreen {
    case selection
    case steps
    case gemini
}

// MARK: - FALL-AUSWAHL
struct CaseSelectionView: View {
    @ObservedObject var appVM: AppViewModel

    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "tooth.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "2D6A4F"))
                    Text("ZahnChallenge")
                        .font(.largeTitle).bold()
                    Text("Wähle einen Fall")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.top, 60)

                CaseCard(dentalCase: appVM.fall1) {
                    appVM.selectCase(appVM.fall1)
                }
                Spacer()
            }
            .padding()
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
                    Text(dentalCase.title).font(.headline).foregroundColor(.white)
                    Text(dentalCase.subtitle).font(.subheadline).foregroundColor(.white.opacity(0.85))
                    Text("\(dentalCase.steps.count) Schritte").font(.caption).foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.white)
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

// MARK: - SCHRITTE VIEW (Schritte 1–7, 9, 10)
struct ChallengeStepsView: View {
    @ObservedObject var appVM: AppViewModel

    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()
            VStack(spacing: 0) {

                // ── Topbar ──
                HStack {
                    Button("← Fälle") { appVM.returnToSelection() }
                        .foregroundColor(Color(hex: "2D6A4F"))
                    Spacer()
                    Text(appVM.selectedCase?.title ?? "")
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    // Platzhalter für Symmetrie
                    Text("← Fälle").foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 56)
                .padding(.bottom, 8)
                .background(Color.white.shadow(color: .black.opacity(0.05), radius: 4, y: 2))

                ProgressView(value: appVM.progressValue)
                    .tint(Color(hex: "2D6A4F"))
                    .padding(.horizontal)
                    .padding(.vertical, 6)

                if let step = appVM.currentStep {
                    ScrollView {
                        VStack(spacing: 20) {
                            StepHeaderView(
                                stepNumber: step.id,
                                total: appVM.selectedCase?.steps.count ?? 0,
                                title: step.title
                            )
                            StepContentCard(description: step.description)

                            // Schritt 8: Button zum Wechseln auf Gemini-Screen
                            if step.isUploadStep {
                                Button {
                                    appVM.currentScreen = .gemini
                                } label: {
                                    HStack {
                                        Image(systemName: "brain.head.profile")
                                        Text("Zur KI-Auswertung")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "2D6A4F")))
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 100)
                    }
                }

                StepNavButtons(appVM: appVM)
            }
        }
    }
}

// MARK: - GEMINI SCREEN (Schritt 8 – eigener Screen)
struct GeminiScreenView: View {
    @ObservedObject var appVM: AppViewModel

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isLoadingPhoto: Bool = false

    private var geminiVM: GeminiViewModel { appVM.geminiViewModel }
    private var prompt: String { appVM.selectedCase?.geminiPrompt ?? "" }

    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()
            VStack(spacing: 0) {

                // ── Topbar ──
                HStack {
                    Button {
                        appVM.currentScreen = .steps
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Zurück")
                        }
                        .foregroundColor(Color(hex: "2D6A4F"))
                    }
                    Spacer()
                    Text("Foto & KI-Auswertung")
                        .font(.headline)
                    Spacer()
                    // Platzhalter
                    Text("Zurück").foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 56)
                .padding(.bottom, 12)
                .background(Color.white.shadow(color: .black.opacity(0.05), radius: 4, y: 2))

                ScrollView {
                    VStack(spacing: 20) {

                        Text("Lade ein Foto deiner Übungsarbeit hoch.\nDie KI bewertet Zahn 11 und die Splint-Anlage.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)

                        // ── Foto-Bereich ──
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "E8F5E9"))
                                    .frame(height: 240)

                                if isLoadingPhoto {
                                    VStack(spacing: 10) {
                                        ProgressView()
                                        Text("Foto wird geladen…")
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                } else if let img = geminiVM.uploadedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 240)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(alignment: .bottomTrailing) {
                                            Label("Ändern", systemImage: "pencil.circle.fill")
                                                .font(.caption)
                                                .padding(8)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Capsule())
                                                .padding(10)
                                        }
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 44))
                                            .foregroundColor(Color(hex: "2D6A4F"))
                                        Text("Foto auswählen")
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "2D6A4F"))
                                        Text("Tippe zum Hochladen")
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .task(id: selectedItem) {
                            guard let item = selectedItem else { return }
                            await MainActor.run { isLoadingPhoto = true }
                            do {
                                if let data = try await item.loadTransferable(type: Data.self),
                                   let raw = UIImage(data: data) {
                                    let scaled = await Task.detached(priority: .userInitiated) {
                                        raw.scaledToMax(1024)
                                    }.value
                                    await MainActor.run {
                                        geminiVM.uploadedImage = scaled
                                        geminiVM.feedbackText = nil
                                        geminiVM.showFeedback = false
                                        geminiVM.errorMessage = nil
                                        isLoadingPhoto = false
                                    }
                                } else {
                                    await MainActor.run {
                                        geminiVM.errorMessage = "Foto konnte nicht geladen werden."
                                        isLoadingPhoto = false
                                    }
                                }
                            } catch {
                                await MainActor.run {
                                    geminiVM.errorMessage = "Fehler: \(error.localizedDescription)"
                                    isLoadingPhoto = false
                                }
                            }
                        }

                        // ── Abgabe-Button ──
                        Button {
                            Task {
                                await geminiVM.evaluate(prompt: prompt)
                            }
                        } label: {
                            HStack {
                                if geminiVM.isEvaluating {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(geminiVM.isEvaluating ? "KI wertet aus…" : "Abgeben & KI-Auswertung starten")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(geminiVM.uploadedImage == nil || isLoadingPhoto
                                          ? Color.gray.opacity(0.4)
                                          : Color(hex: "2D6A4F"))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(geminiVM.uploadedImage == nil || geminiVM.isEvaluating || isLoadingPhoto)

                        // ── Ladeindikator während Auswertung ──
                        if geminiVM.isEvaluating {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.4)
                                Text("Gemini analysiert dein Foto…")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                            .shadow(color: .black.opacity(0.06), radius: 8)
                        }

                        // ── Fehler/Demo-Hinweis ──
                        if let errMsg = geminiVM.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(errMsg)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.1)))
                        }

                        // ── Auswertungsergebnis ──
                        if geminiVM.showFeedback, let feedback = geminiVM.feedbackText {
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
                                    .lineSpacing(5)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "E8F5E9")))

                            // ── Zurück-zum-Start-Button (erscheint nach Auswertung) ──
                            Button {
                                appVM.returnToSelection()
                            } label: {
                                HStack {
                                    Image(systemName: "house.fill")
                                    Text("Zurück zum Startbildschirm")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: "2D6A4F"), lineWidth: 2)
                                )
                                .foregroundColor(Color(hex: "2D6A4F"))
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
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
                Circle().fill(Color(hex: "2D6A4F")).frame(width: 44, height: 44)
                Text("\(stepNumber)").font(.headline).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Schritt \(stepNumber) von \(total)")
                    .font(.caption).foregroundColor(.secondary)
                Text(title).font(.title3).bold()
            }
            Spacer()
        }
    }
}

// MARK: - NORMALE SCHRITT-KARTE
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

// MARK: - NAVIGATIONS-BUTTONS (Vor/Zurück)
struct StepNavButtons: View {
    @ObservedObject var appVM: AppViewModel

    var body: some View {
        HStack(spacing: 16) {
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

            Button(action: appVM.isLastStep ? appVM.returnToSelection : appVM.nextStep) {
                HStack {
                    Text(appVM.isLastStep ? "Abschließen ✓" : "Weiter")
                    if !appVM.isLastStep { Image(systemName: "chevron.right") }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "2D6A4F")))
                .foregroundColor(.white)
            }
        }
        .padding()
        .background(.white)
        .shadow(color: .black.opacity(0.05), radius: 4, y: -2)
    }
}

// MARK: - UIIMAGE SKALIERUNG
extension UIImage {
    func scaledToMax(_ maxDimension: CGFloat) -> UIImage {
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        guard scale < 1.0 else { return self }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - HEX COLOR
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}
