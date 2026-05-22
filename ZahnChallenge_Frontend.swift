import SwiftUI

// MARK: - ROOT VIEW
struct ContentView: View {
    @StateObject private var state = AppState()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        TopBarView()
                        SearchBarView()
                        CategoryPillsView(state: state)
                        HeroBannerView()
                        CasesSectionView(state: state)
                        Spacer(minLength: 120)
                    }
                }
                BottomNavView(state: state)
            }
            .background(Color(hex: "F9FAFB"))
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $state.showAvatarSheet) {
                AvatarSheetView()
                    .presentationDetents([.fraction(0.55)])
                    .presentationCornerRadius(24)
            }
        }
    }
}

// MARK: - TOP BAR
struct TopBarView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Willkommen zurück")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6B7280"))
                Text("Max Mustermann")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "084B83"))
            }
            Spacer()
            ZStack {
                Circle().fill(Color(hex: "084B83")).frame(width: 44, height: 44)
                Image(systemName: "bell.fill").foregroundColor(.white).font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }
}

// MARK: - SEARCH BAR
struct SearchBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "727781"))
                    .padding(.leading, 12)
                Text("Fall suchen...")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6B7280"))
                Spacer()
            }
            .frame(height: 44)
            .background(Color(hex: "F3F4F6"))
            .clipShape(Capsule())

            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color(hex: "084B83"))
                    .frame(width: 44, height: 44)
                    .overlay(Capsule().stroke(Color(hex: "727781"), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - CATEGORY PILLS
struct CategoryPillsView: View {
    @ObservedObject var state: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(state.categories, id: \.self) { cat in
                    Button(action: { state.selectedCategory = cat }) {
                        Text(cat)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(state.selectedCategory == cat ? .white : Color(hex: "084B83"))
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(state.selectedCategory == cat ? Color(hex: "084B83") : .white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: "084B83"), lineWidth: state.selectedCategory == cat ? 0 : 1))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - HERO BANNER
struct HeroBannerView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color(hex: "084B83"), Color(hex: "1A6FBA")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(height: 160)

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 240, y: 20)

            HStack(alignment: .bottom, spacing: 0) {
                Image("dr_lukas")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 140)
                    .clipped()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Jetzt lernen &\nPunkte sammeln!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(2)
                    Text("3 interaktive Patientenfälle\nwarten auf dich")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.9))
                    Button(action: {}) {
                        Text("Los geht\'s")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "084B83"))
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.leading, 12)
                .padding(.bottom, 20)
                Spacer()
            }
        }
        .frame(height: 160)
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - CASES SECTION
struct CasesSectionView: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Patientenfälle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Alle sehen").font(.system(size: 14, weight: .medium))
                        Image(systemName: "arrow.right").font(.system(size: 11))
                    }
                    .foregroundColor(Color(hex: "084B83"))
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(state.cases) { patientCase in
                        NavigationLink(destination: CaseDetailView(patientCase: patientCase)) {
                            CaseCardView(patientCase: patientCase)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - CASE CARD
struct CaseCardView: View {
    let patientCase: PatientCase

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [patientCase.gradientStart, patientCase.gradientEnd],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 96)

                Image(systemName: patientCase.sfSymbol)
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.white.opacity(0.75))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let badge = patientCase.badge, let badgeBG = patientCase.badgeBG, let badgeText = patientCase.badgeText {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badgeText)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(badgeBG)
                        .clipShape(Capsule())
                        .padding(8)
                }
            }
            .frame(height: 96)

            VStack(alignment: .leading, spacing: 5) {
                Text(patientCase.category)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "727781"))
                    .tracking(0.5)

                Text(patientCase.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= patientCase.difficulty ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(i <= patientCase.difficulty ? patientCase.starColor : Color(hex: "D1D5DB"))
                    }
                    Text(patientCase.difficultyLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "727781"))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E5E7EB")).frame(height: 5)
                        RoundedRectangle(cornerRadius: 4).fill(Color(hex: "084B83"))
                            .frame(width: max(geo.size.width * patientCase.progress, 0), height: 5)
                    }
                }.frame(height: 5)

                HStack {
                    Spacer()
                    Text("\(Int(patientCase.progress * Double(patientCase.totalSteps))) / \(patientCase.totalSteps) Schritte")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "9CA3AF"))
                }
            }
            .padding(12)
        }
        .frame(width: 200)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "084B83").opacity(0.08), radius: 8, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "EFF4FF"), lineWidth: 1))
    }
}

// MARK: - BOTTOM NAV
struct BottomNavView: View {
    @ObservedObject var state: AppState

    var body: some View {
        HStack {
            Spacer()
            Button(action: { state.selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: "house.fill").font(.system(size: 20))
                    Text("Startseite").font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(state.selectedTab == 0 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(state.selectedTab == 0 ? Color(hex: "C9F0FF") : .clear)
                .clipShape(Capsule())
            }
            Spacer()
            Button(action: { state.selectedTab = 1 }) {
                VStack(spacing: 4) {
                    Image(systemName: "trophy.fill").font(.system(size: 20))
                    Text("Ranking").font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(state.selectedTab == 1 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
            }
            Spacer()
            ZStack(alignment: .top) {
                Button(action: { state.selectedTab = 2 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill").font(.system(size: 20))
                        Text("Chat").font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(state.selectedTab == 2 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                }
                .padding(.top, 30)

                Button(action: { state.showAvatarSheet = true }) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(Color(hex: "084B83"))
                            .frame(width: 50, height: 50)
                            .shadow(color: Color(hex: "084B83").opacity(0.35), radius: 8, y: 3)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .overlay(
                                Image("dr_lukas")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 46, height: 46)
                                    .clipShape(Circle())
                            )
                        Circle().fill(Color.red).frame(width: 16, height: 16)
                            .overlay(Text("1").font(.system(size: 9, weight: .bold)).foregroundColor(.white))
                            .offset(x: 2, y: -2)
                    }
                }
                .offset(y: -28)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(.white)
        .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
    }
}

// MARK: - AVATAR SHEET
struct AvatarSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color(hex: "E5E7EB")).frame(width: 40, height: 4).padding(.top, 12)

            HStack(spacing: 12) {
                Circle().fill(Color(hex: "C9F0FF")).frame(width: 52, height: 52)
                    .overlay(Image("dr_lukas").resizable().scaledToFill().frame(width: 48, height: 48).clipShape(Circle()))
                VStack(alignment: .leading) {
                    Text("Dr. Lukas").font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                    Text("Dein persönlicher Lernassistent").font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 24)).foregroundColor(Color(hex: "D1D5DB"))
                }
            }
            .padding(.horizontal, 20)

            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(hex: "C9F0FF"))
                    Text("Hallo Max! Ich bin Dr. Lukas.\nSoll ich dir die App kurz erklären?")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "084B83")).padding(14)
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            VStack(spacing: 10) {
                Button(action: { dismiss() }) {
                    Text("Ja, zeig mir alles!")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color(hex: "084B83")).clipShape(Capsule())
                }
                Button(action: { dismiss() }) {
                    Text("Ich kenne mich aus, danke!")
                        .font(.system(size: 15, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .overlay(Capsule().stroke(Color(hex: "084B83"), lineWidth: 1.5))
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(["Fall 1 starten", "Was sind Badges?", "Mein Fortschritt"], id: \.self) { chip in
                        Label(chip, systemImage: chip == "Fall 1 starten" ? "play.circle" : chip == "Was sind Badges?" ? "questionmark.circle" : "chart.bar")
                            .font(.system(size: 12, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color(hex: "EAFFFD")).clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
}

// MARK: - CASE DETAIL
struct CaseDetailView: View {
    let patientCase: PatientCase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [patientCase.gradientStart, patientCase.gradientEnd],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 20))

                    Image(systemName: patientCase.sfSymbol)
                        .font(.system(size: 72, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center).padding(.bottom, 30)

                    HStack {
                        Label("Notfall", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.red.opacity(0.85)).clipShape(Capsule())
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(1...3, id: \.self) { i in
                                Image(systemName: i <= patientCase.difficulty ? "star.fill" : "star")
                                    .font(.system(size: 11))
                                    .foregroundColor(i <= patientCase.difficulty ? .yellow : .white.opacity(0.4))
                            }
                            Text(patientCase.difficultyLabel).font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.black.opacity(0.25)).clipShape(Capsule())
                    }
                    .padding(12)
                }
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill").foregroundColor(Color(hex: "084B83")).font(.system(size: 20))
                        VStack(alignment: .leading) {
                            Text("Ignaz Grünzinger").font(.system(size: 17, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                            Text("23 Jahre | Maurergeselle").font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                        }
                    }
                    Divider()
                    Text("\"Ich bin über eine Gehwegplatte gestolpert und mit dem Gesicht gegen einen Blumentopf gefallen. Sofort spürte ich starken Schmerz in den Schneidezähnen.\"")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "374151")).italic().lineSpacing(4)
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Label("Notdienst 23:00", systemImage: "clock.fill")
                        Label("Obere Schneidezähne", systemImage: "mouth.fill")
                        Label("Rettungsdienst", systemImage: "cross.fill")
                    }
                    .font(.system(size: 12, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Fallverlauf").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "084B83")).padding(.horizontal, 16)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(["Anamnese","Konsilium","Untersuchung","Aufbewahrung","Diagnose","Therapie"].enumerated()), id: \.0) { i, step in
                                VStack(spacing: 4) {
                                    Circle().fill(i == 0 ? Color(hex: "084B83") : Color(hex: "E5E7EB"))
                                        .frame(width: 28, height: 28)
                                        .overlay(Text("\(i+1)").font(.system(size: 11, weight: .bold)).foregroundColor(i == 0 ? .white : Color(hex: "9CA3AF")))
                                    Text(step).font(.system(size: 9)).foregroundColor(i == 0 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                NavigationLink(destination: Step1FreeTextView()) {
                    Text("Fall starten")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "084B83").opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
            .padding(.top, 16)
        }
        .navigationTitle(patientCase.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
    }
}

// MARK: - STEP 1: FREITEXT
struct Step1FreeTextView: View {
    @State private var inputText = ""
    @State private var showHint = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 1, total: 6, score: 0)

                Label("Erste Gedanken", systemImage: "text.bubble")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "FFD6A5")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 10) {
                    Text("OFFENE FRAGE").font(.system(size: 10, weight: .bold)).foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Bevor Sie den Patienten untersuchen – welche Gedanken gehen Ihnen durch den Kopf?")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Denken Sie laut nach. Es gibt keine falsche Antwort.")
                        .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $inputText)
                        .frame(height: 140).padding(12)
                        .background(Color(hex: "F9FAFB"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(inputText.isEmpty ? Color(hex: "E5E7EB") : Color(hex: "A5D8FF"), lineWidth: 1.5))
                    if inputText.isEmpty {
                        Text("Ihre Überlegungen hier eingeben...")
                            .foregroundColor(Color(hex: "9CA3AF")).font(.system(size: 14)).italic()
                            .padding(20).allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 16)

                Text("\(inputText.count) / 300")
                    .font(.system(size: 11)).foregroundColor(Color(hex: "9CA3AF"))
                    .frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal, 16)

                DrLukasHintView(text: "Denken Sie nicht nur an Zähne – der Patient hatte einen Sturz am Kopf! An Neurologie und MKG-Chirurgie denken.")

                NavigationLink(destination: Step2MCQView()) {
                    Text("Weiter")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(inputText.isEmpty ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(inputText.isEmpty)
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 1 von 6")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
    }
}

// MARK: - STEP 2: MCQ
struct Step2MCQView: View {
    @State private var selectedAnswer: Int? = nil
    @State private var submitted = false

    let options = ["MKG-Chirurgie & Neurologie", "Urologie", "Kardiologie", "Dermatologie"]
    let correctIndex = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 2, total: 6, score: submitted ? 10 : 0)

                Label("Konsilium", systemImage: "person.2.fill")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "C9F0FF")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 8) {
                    Text("SINGLE CHOICE").font(.system(size: 10, weight: .bold)).foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Welche Fachrichtungen sollten Sie konsiliarisch hinzuziehen?")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Eine Antwort ist richtig").font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(0..<options.count, id: \.self) { i in
                        Button(action: { if !submitted { selectedAnswer = i } }) {
                            HStack {
                                Text(options[i])
                                    .font(.system(size: 15, weight: selectedAnswer == i ? .semibold : .regular))
                                    .foregroundColor(Color(hex: "0B1C30"))
                                Spacer()
                                if submitted {
                                    Image(systemName: i == correctIndex ? "checkmark.circle.fill" : (selectedAnswer == i ? "xmark.circle.fill" : "circle"))
                                        .foregroundColor(i == correctIndex ? .green : (selectedAnswer == i ? .red : Color(hex: "E5E7EB")))
                                }
                            }
                            .padding(16)
                            .background(answerBG(i))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(answerBorder(i), lineWidth: selectedAnswer == i ? 2 : 1))
                        }
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    DrLukasHintView(text: "An jedem Zahn hängt ein Mensch! Bei Kopfverletzungen immer an Neurologie und MKG-Chirurgie denken.")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Button(action: { if !submitted { withAnimation { submitted = true } } }) {
                    Text(submitted ? "Weiter" : "Antwort bestätigen")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(selectedAnswer == nil ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedAnswer == nil)
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 2 von 6")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
    }

    func answerBG(_ i: Int) -> Color {
        if !submitted { return selectedAnswer == i ? Color(hex: "A5D8FF") : .white }
        if i == correctIndex { return Color(hex: "CAFFBF") }
        if selectedAnswer == i { return Color(hex: "FFD6D6") }
        return .white
    }

    func answerBorder(_ i: Int) -> Color {
        if !submitted { return selectedAnswer == i ? Color(hex: "084B83") : Color(hex: "E5E7EB") }
        if i == correctIndex { return .green }
        if selectedAnswer == i { return .red }
        return Color(hex: "E5E7EB")
    }
}

// MARK: - REUSABLE: Progress Bar
struct ProgressBarView: View {
    let step: Int
    let total: Int
    let score: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Schritt \(step) von \(total)")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                Spacer()
                if score > 0 {
                    Text("+\(score) Punkte").font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                } else {
                    Text("\(score) Punkte").font(.system(size: 12)).foregroundColor(Color(hex: "9CA3AF"))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E5E7EB")).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Color(hex: "084B83"))
                        .frame(width: geo.size.width * (Double(step) / Double(total)), height: 6)
                }
            }.frame(height: 6)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - REUSABLE: Dr. Lukas Hint
struct DrLukasHintView: View {
    let text: String
    @State private var showHint = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { showHint.toggle() } }) {
                HStack(spacing: 8) {
                    Circle().fill(Color(hex: "C9F0FF")).frame(width: 30, height: 30)
                        .overlay(Image("dr_lukas").resizable().scaledToFill().frame(width: 28, height: 28).clipShape(Circle()))
                    Text("Dr. Lukas hat einen Tipp")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                    Spacer()
                    Image(systemName: showHint ? "chevron.up" : "chevron.right")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "084B83"))
                }
                .padding(14)
            }
            if showHint {
                Text(text)
                    .font(.system(size: 13)).foregroundColor(Color(hex: "084B83"))
                    .padding([.horizontal, .bottom], 14)
            }
        }
        .background(Color(hex: "EAFFFD"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}
