
//  ZahnChallenge_GeminiAPI.swift
//  Hackathon_Zahnmed_Challenge
//
//  Zuständigkeit: Gemini REST API Service + Prompts + ViewModel

import Foundation
import UIKit
import Combine

// MARK: - API KEY HELPER

enum APIKey {
    static var `default`: String {
        
        let hardcodedKey = "AIzaSyBoFn8hfdl69-J4AgjVcqug7Uq7V2N0zUA"
        
        // Fallback auf plist (für Produktion empfohlen)
        if let path = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let key = plist["API_KEY"] as? String, !key.isEmpty {
            return key
        }
        return hardcodedKey
    }
}

// MARK: - GEMINI RESPONSE MODEL
struct GeminiResponse: Codable {
    let candidates: [Candidate]?

    struct Candidate: Codable {
        let content: Content
    }
    struct Content: Codable {
        let parts: [Part]
    }
    struct Part: Codable {
        let text: String?
    }
}

// MARK: - GEMINI SERVICE
class GeminiService {
    static let shared = GeminiService()
    private init() {}

    private let model = "gemini-1.5-flash"

    func evaluate(imageData: Data, prompt: String) async throws -> String {
        let key = APIKey.default
        guard !key.isEmpty, key != "DEIN-API-KEY-HIER" else {
            throw GeminiError.noAPIKey
        }

        guard let url = URL(string:
            "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(key)"
        ) else {
            throw GeminiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "contents": [[
                "parts": [
                    ["text": prompt],
                    ["inline_data": [
                        "mime_type": "image/jpeg",
                        "data": imageData.base64EncodedString()
                    ]]
                ]
            ]],
            "generationConfig": [
                "maxOutputTokens": 300,
                "temperature": 0.4
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let msg = String(data: data, encoding: .utf8) ?? "Unbekannter API-Fehler"
            throw GeminiError.apiError(http.statusCode, msg)
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates?.first?.content.parts.first?.text else {
            throw GeminiError.emptyResponse
        }
        return text
    }
}

// MARK: - FEHLERTYPEN
enum GeminiError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case apiError(Int, String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Kein API Key gefunden. Bitte in ZahnChallenge_GeminiAPI.swift eintragen."
        case .invalidURL:
            return "Ungültige API URL."
        case .apiError(let code, let msg):
            return "API Fehler \(code): \(msg)"
        case .emptyResponse:
            return "Gemini hat keine Auswertung zurückgegeben."
        }
    }
}

// MARK: - PROMPTS
enum GeminiPrompts {
    static let fall1_upload = """
    Du bist ein erfahrener Zahnarzt-Tutor an der Universität Regensburg.
    Ein Zahnmedizinstudierender hat eine Übungsbehandlung am 3D-Modell durchgeführt
    und ein Foto hochgeladen.

    Aufgabe des Studierenden war:
    - Repositionierung des avulsierten Zahns 11 in die Alveole
    - Anlage eines Titan-Trauma-Splints

    Bewerte das Foto nach genau diesen 3 Punkten:
    1. ✅ Position Zahn 11 – korrekt reponiert? (Höhe, Achse im Vergleich zu Nachbarzähnen)
    2. 🔧 Splint-Anlage – korrekt? (Ausdehnung, Fixierung, Okklusionsfreiheit)
    3. 💡 Wichtigster Verbesserungshinweis für den Studierenden

    Regeln:
    - Antworte auf Deutsch
    - Maximal 130 Wörter
    - Ermutigender, lehrender Ton – wie ein guter Tutor
    - Beginne direkt mit Punkt 1, kein einleitendes Satz
    - Hinweis: Dies ist ein anonymisiertes 3D-Lehrmodell, keine echten Patientendaten
    """
}

// MARK: - GEMINI VIEW MODEL
class GeminiViewModel: ObservableObject {
    @Published var uploadedImage: UIImage? = nil
    @Published var feedbackText: String? = nil
    @Published var isEvaluating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showFeedback: Bool = false

    // Wird vom Frontend in Schritt 8 aufgerufen
    @MainActor
    func evaluate(prompt: String) async {
        guard let image = uploadedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Bitte zuerst ein Foto hochladen."
            return
        }

        isEvaluating = true
        errorMessage = nil
        feedbackText = nil
        showFeedback = false

        do {
            let result = try await GeminiService.shared.evaluate(
                imageData: imageData,
                prompt: prompt
            )
            feedbackText = result
            showFeedback = true
        } catch GeminiError.noAPIKey {
            // Demo-Fallback wenn kein Key gesetzt
            feedbackText = GeminiViewModel.mockFeedback
            showFeedback = true
            errorMessage = "⚠️ Demo-Modus: API Key fehlt in ZahnChallenge_GeminiAPI.swift"
        } catch {
            feedbackText = GeminiViewModel.mockFeedback
            showFeedback = true
            errorMessage = "⚠️ Demo-Modus aktiv (\(error.localizedDescription))"
        }

        isEvaluating = false
    }

    func reset() {
        uploadedImage = nil
        feedbackText = nil
        errorMessage = nil
        showFeedback = false
        isEvaluating = false
    }

    static let mockFeedback = """
    ✅ Zahn 11 ist korrekt reponiert – Höhe und Achse stimmen gut mit den Nachbarzähnen überein. Sehr sauber!

    🔧 Die Splint-Anlage ist solide. Er könnte etwas weiter nach apikal reichen, um die Stabilität zu verbessern.

    💡 Prüfe vor dem endgültigen Zementieren noch die Okklusion – nach Traumata ist sie häufig verändert und kann die Heilung negativ beeinflussen.
    """
}
