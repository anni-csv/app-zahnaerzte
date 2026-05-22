//
//  SplashScreenView.swift
//  Hackathon_Zahnmed_Challenge
//
//  Zeigt beim App-Start das Intro-Video (MicrosoftTeams-video.mp4).
//  Danach automatisch weiter zur ContentView.
//

import SwiftUI
import AVKit

struct SplashScreenView: View {
    @State private var isFinished = false
    @State private var player: AVPlayer? = nil

    var body: some View {
        if isFinished {
            ContentView()
        } else {
            ZStack {
                Color.black.ignoresSafeArea()

                if let player = player {
                    VideoPlayerView(player: player)
                        .ignoresSafeArea()
                }
            }
            .onAppear {
                setupPlayer()
            }
        }
    }

    private func setupPlayer() {
        // Video muss als "MicrosoftTeams-video" in den Xcode-Target-Ressourcen liegen
        guard let url = Bundle.main.url(forResource: "MicrosoftTeams-video", withExtension: "mp4") else {
            // Video nicht gefunden → direkt zur App
            isFinished = true
            return
        }

        let avPlayer = AVPlayer(url: url)
        self.player = avPlayer

        // Wenn Video endet → zur App wechseln
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                isFinished = true
            }
        }

        avPlayer.play()
    }
}

// Kleiner UIViewControllerRepresentable-Wrapper damit das Video
// fullscreen ohne Controls angezeigt wird
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
