import WidgetKit
import SwiftUI

// MARK: - Color Helper
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
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Timeline Entry
struct Fall1Entry: TimelineEntry {
    let date: Date
    let isCompleted: Bool  // NEU
}

// MARK: - Timeline Provider
struct Fall1Provider: TimelineProvider {
    func placeholder(in context: Context) -> Fall1Entry {
        Fall1Entry(date: Date(), isCompleted: false)
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (Fall1Entry) -> Void) {
        let completed = UserDefaults.standard.bool(forKey: "fall1_completed")
        completion(Fall1Entry(date: Date(), isCompleted: completed))
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<Fall1Entry>) -> Void) {
        let completed = UserDefaults.standard.bool(forKey: "fall1_completed")
        let entry = Fall1Entry(date: Date(), isCompleted: completed)
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}

// MARK: - Small Widget View
struct Fall1WidgetSmallView: View {
    let isCompleted: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                // Top Badge
                HStack {
                    Label(isCompleted ? "ERLEDIGT" : "NOTFALL",
                          systemImage: isCompleted ? "checkmark.seal.fill" : "cross.case.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(isCompleted ? Color(hex: "166534") : Color(hex: "084B83"))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.85))
                        .clipShape(Capsule())
                    Spacer()
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                        .foregroundColor(isCompleted ? Color(hex: "166534") : Color(hex: "084B83"))
                        .font(.system(size: 15))
                }

                Spacer()

                // Icon
                Image(systemName: isCompleted ? "checkmark.seal.fill" : "cross.case.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(isCompleted ? Color(hex: "166534").opacity(0.3) : Color(hex: "084B83").opacity(0.25))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(y: 8)

                // Titel
                Text("FALL 1")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isCompleted ? Color(hex: "166534").opacity(0.7) : Color(hex: "084B83").opacity(0.6))
                    .tracking(1.0)

                Text("Volksfest-\nUnfall")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "0B1C30"))
                    .lineLimit(2)

                // Status unten
                if isCompleted {
                    Text("✅ Abgeschlossen")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(hex: "166534"))
                        .padding(.top, 6)
                } else {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.5))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "084B83"))
                                .frame(width: 0, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, 6)

                    Text("0 / 8 Schritte")
                        .font(.system(size: 8))
                        .foregroundColor(Color(hex: "6B7280"))
                        .padding(.top, 4)
                }
            }
            .padding(12)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: isCompleted
                    ? [Color(hex: "CAFFBF"), Color(hex: "EAFFED")]   // Grün wenn fertig
                    : [Color(hex: "FFD6A5"), Color(hex: "FFEFCF")],  // Orange wenn offen
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Medium Widget View
struct Fall1WidgetMediumView: View {
    let isCompleted: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 14) {
                // Linke Seite: Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isCompleted ? Color(hex: "166534").opacity(0.12) : Color(hex: "084B83").opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: isCompleted ? "checkmark.seal.fill" : "cross.case.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(isCompleted ? Color(hex: "166534") : Color(hex: "084B83"))
                }

                // Rechte Seite: Infos
                VStack(alignment: .leading, spacing: 6) {
                    Label(isCompleted ? "ABGESCHLOSSEN" : "NOTFALLBEHANDLUNG",
                          systemImage: isCompleted ? "checkmark.seal.fill" : "cross.case.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(isCompleted ? Color(hex: "166534") : Color(hex: "084B83"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Capsule())

                    Text("Volksfest-Unfall")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "0B1C30"))

                    Text("Patient: Ignaz Grünzinger · 8 Schritte")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "6B7280"))

                    // Sterne
                    HStack(spacing: 3) {
                        ForEach(1...3, id: \.self) { i in
                            Image(systemName: i <= 2 ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(i <= 2 ? Color(hex: "F59E0B") : Color(hex: "D1D5DB"))
                        }
                        Text("Mittel")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "6B7280"))
                    }

                    Spacer()

                    // Status unten
                    HStack {
                        if isCompleted {
                            Text("✅ Fall abgeschlossen")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "166534"))
                        } else {
                            Text("0 / 8 Schritte")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "6B7280"))
                            Spacer()
                            Text("Jetzt starten →")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "084B83"))
                        }
                    }
                }

                Spacer()
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: isCompleted
                    ? [Color(hex: "CAFFBF"), Color(hex: "EAFFED")]   // Grün wenn fertig
                    : [Color(hex: "FFD6A5"), Color(hex: "FFEFCF")],  // Orange wenn offen
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Unified Entry View
struct Fall1WidgetEntryView: View {
    var entry: Fall1Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Link(destination: URL(string: "zahnaerzte://fall1")!) {
            switch family {
            case .systemSmall:
                Fall1WidgetSmallView(isCompleted: entry.isCompleted)
            case .systemMedium:
                Fall1WidgetMediumView(isCompleted: entry.isCompleted)
            default:
                Fall1WidgetSmallView(isCompleted: entry.isCompleted)
            }
        }
    }
}

// MARK: - Widget Declaration
struct Fall1Widget: Widget {
    let kind: String = "Fall1Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Fall1Provider()) { entry in
            Fall1WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Fall 1 – Volksfest-Unfall")
        .description("Öffnet Fall 1 direkt in der Zahnärzte-App.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
