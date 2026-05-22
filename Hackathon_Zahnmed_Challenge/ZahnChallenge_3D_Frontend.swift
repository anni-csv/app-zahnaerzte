//
//  ZahnChallenge_3D_Frontend.swift
//  Hackathon_Zahnmed_Challenge
//
//  3D-Modell-Viewer: Übersicht + Detailansicht
//  Verwendet SceneKit (kein ARKit nötig, läuft auf allen Geräten)
//

import SwiftUI
import SceneKit
import QuickLook

// ─────────────────────────────────────────────
// MARK: - BUTTON auf der Startseite
// In ZahnChallenge_Frontend.swift direkt nach HeroBannerView() einfügen:
//
//   NavigationLink(destination: ModelOverviewView()) {
//       Modell3DButtonView()
//   }
//   .padding(.horizontal, 16)
// ─────────────────────────────────────────────

struct Modell3DButtonView: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "rotate.3d")
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color(hex: "1A7A4A"))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("3D Modelle ansehen")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                Text("Ausgangsbefund · Fehlerhaft · Korrekt")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// ─────────────────────────────────────────────
// MARK: - ÜBERSICHTSSEITE
// ─────────────────────────────────────────────

struct ModelOverviewView: View {

    let modelle: [ZahnModell] = [
        ZahnModell(id: 1,
                   name: "Ausgangsbefund",
                   beschreibung: "Zustand vor der Behandlung",
                   dateiname: "Hackathon_Fall1",
                   farbe: "084B83",
                   icon: "magnifyingglass.circle.fill"),
        ZahnModell(id: 2,
                   name: "Fehlerhafte Versorgung",
                   beschreibung: "Typische Behandlungsfehler erkennen",
                   dateiname: "Hackathon_Fall1_Fehlerhaft",
                   farbe: "C0392B",
                   icon: "xmark.circle.fill"),
        ZahnModell(id: 3,
                   name: "Korrekte Versorgung",
                   beschreibung: "Optimales Behandlungsergebnis",
                   dateiname: "Hackathon_Fall1_Repariert",
                   farbe: "1A7A4A",
                   icon: "checkmark.circle.fill")
    ]

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("3D Modelle")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "0B1C30"))
                    Text("Fall 1 · Kavitätenpräparation")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Info-Banner
                HStack(spacing: 12) {
                    Image(systemName: "rotate.3d")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "084B83"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Interaktive 3D-Ansicht")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                        Text("Tippe auf ein Modell · Drehen mit dem Finger")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color(hex: "EBF3FB"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)

                // Modell-Karten
                VStack(spacing: 16) {
                    ForEach(modelle) { modell in
                        NavigationLink(destination: ModelDetailView(modell: modell)) {
                            ModellKarteView(modell: modell)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)

                // Lerntipp
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text("Lerntipp")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                    }
                    Text("Vergleiche die drei Modelle miteinander. Erkennst du den Unterschied zwischen der fehlerhaften und der korrekten Versorgung?")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "374151"))
                        .lineSpacing(4)
                }
                .padding(14)
                .background(Color(hex: "FFFBEB"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "FCD34D"), lineWidth: 1))
                .padding(.horizontal, 16)

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(Color(hex: "F9FAFB"))
        .navigationTitle("3D Modelle")
        .navigationBarTitleDisplayMode(.large)
    }
}

// ─────────────────────────────────────────────
// MARK: - MODELL-KARTE
// ─────────────────────────────────────────────

struct ModellKarteView: View {
    let modell: ZahnModell

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: modell.farbe).opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: modell.icon)
                    .font(.system(size: 26))
                    .foregroundColor(Color(hex: modell.farbe))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(modell.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                Text(modell.beschreibung)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6B7280"))
                HStack(spacing: 4) {
                    Image(systemName: "cube.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("3D Modell ansehen")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "084B83"))
                }
                .padding(.top, 2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// ─────────────────────────────────────────────
// MARK: - DETAIL-ANSICHT
// ─────────────────────────────────────────────

struct ModelDetailView: View {
    let modell: ZahnModell
    @State private var showQuickLook = false
    @State private var modelLoaded = false
    @State private var modelError = false

    var usdzURL: URL? {
        Bundle.main.url(forResource: modell.dateiname, withExtension: "usdz")
    }

    var body: some View {
        VStack(spacing: 0) {

            // 3D Viewer
            ZStack {
                Color(hex: "F0F4F8")

                if let url = usdzURL {
                    SceneKitView(url: url, onLoaded: {
                        modelLoaded = true
                    }, onError: {
                        modelError = true
                    })
                    if !modelLoaded && !modelError {
                        VStack(spacing: 10) {
                            ProgressView()
                                .scaleEffect(1.3)
                            Text("Modell wird geladen…")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                    }
                } else {
                    // Datei nicht gefunden
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text("Modell nicht gefunden")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                        Text("\(modell.dateiname).usdz")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9CA3AF"))
                    }
                }
            }
            .frame(height: 340)

            // Steuer-Hinweise
            HStack(spacing: 20) {
                Label("Drehen", systemImage: "hand.draw")
                Label("Zoomen", systemImage: "arrow.up.left.and.arrow.down.right")
                Label("Schieben", systemImage: "hand.point.up.left")
            }
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "6B7280"))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "EBF3FB"))

            // Info-Bereich
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(modell.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "0B1C30"))
                            Text("Fall 1 · Kavitätenpräparation")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                        Spacer()
                        Image(systemName: modell.icon)
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: modell.farbe))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Was du hier siehst")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                        Text(modell.lernhinweis)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "374151"))
                            .lineSpacing(5)
                    }
                    .padding(14)
                    .background(Color(hex: modell.farbe).opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // AR-Button — nur anzeigen wenn Datei vorhanden
                    if usdzURL != nil {
                        Button(action: { showQuickLook = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arkit")
                                    .font(.system(size: 16))
                                Text("In AR ansehen (iPhone)")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "084B83"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .sheet(isPresented: $showQuickLook) {
                            if let url = usdzURL {
                                QuickLookView(url: url)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F9FAFB"))
        .navigationTitle(modell.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

// ─────────────────────────────────────────────
// MARK: - SCENEKIT VIEWER (kein ARKit nötig!)
// ─────────────────────────────────────────────

struct SceneKitView: UIViewRepresentable {
    let url: URL
    var onLoaded: (() -> Void)?
    var onError: (() -> Void)?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.defaultCameraController.interactionMode = .orbitTurntable

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let scene = try SCNScene(url: url, options: [
                    SCNSceneSource.LoadingOption.convertToYUp: true,
                    SCNSceneSource.LoadingOption.convertUnitsToMeters: 1.0
                ])

                // Kamera-Node hinzufügen
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                cameraNode.position = SCNVector3(0, 0, 0.3)
                scene.rootNode.addChildNode(cameraNode)

                // Licht hinzufügen
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light?.type = .omni
                lightNode.position = SCNVector3(0, 0.3, 0.3)
                scene.rootNode.addChildNode(lightNode)

                let ambientNode = SCNNode()
                ambientNode.light = SCNLight()
                ambientNode.light?.type = .ambient
                ambientNode.light?.color = UIColor(white: 0.7, alpha: 1.0)
                scene.rootNode.addChildNode(ambientNode)

                DispatchQueue.main.async {
                    scnView.scene = scene
                    onLoaded?()
                }
            } catch {
                print("⚠️ SceneKit Fehler: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onError?()
                }
            }
        }
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

// ─────────────────────────────────────────────
// MARK: - QUICK LOOK (AR auf iPhone)
// ─────────────────────────────────────────────

struct QuickLookView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - DATENMODELL
// ─────────────────────────────────────────────

struct ZahnModell: Identifiable {
    let id: Int
    let name: String
    let beschreibung: String
    let dateiname: String
    let farbe: String
    let icon: String

    var lernhinweis: String {
        switch id {
        case 1: return "Dies ist der Ausgangsbefund vor jeglicher Behandlung. Achte auf Lage und Ausdehnung der Kavität sowie die umliegenden Zahnstrukturen."
        case 2: return "Hier siehst du eine fehlerhafte Versorgung. Typische Fehler: zu steile Wände, insuffiziente Ränder oder falsche Ausdehnung. Kannst du die Fehler identifizieren?"
        case 3: return "Dies ist das korrekte Behandlungsergebnis. Beachte die ideale Kavitätenform, saubere Ränder und die schonende Behandlung der gesunden Zahnsubstanz."
        default: return beschreibung
        }
    }
}
