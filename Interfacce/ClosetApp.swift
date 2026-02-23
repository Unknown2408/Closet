import SwiftUI

@main
struct ClosetApp: App {
    // Ci basta sapere solo se il video è finito
    @State private var splashFinita: Bool = false
    @State private var videoOpacita: Double = 0.0 // Per la dissolvenza in entrata
    @State private var manager = ClosetManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Sfondo nero universale
                Color.black.ignoresSafeArea()
                
                if !splashFinita {
                    // 1. SCHERMATA VIDEO INTRO
                    CustomVideoPlayer(videoName: "ClosetIntro", videoExtension: "mp4")
                        .ignoresSafeArea()
                        .opacity(videoOpacita)
                        .transition(.opacity)
                        .onAppear {
                            // Dissolvenza in ENTRATA del video
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeIn(duration: 1.5)) {
                                    videoOpacita = 1.0
                                }
                            }
                        }
                } else {
                    // 2. HOMEVIEW
                    HomeView()
                        .environment(manager)
                        .transition(.opacity)
                }
            }
            // Gestione globale della transizione (Dissolvenza morbida tra video e Home)
            .animation(.easeInOut(duration: 1.5), value: splashFinita)
            .onAppear {
                // Timer per terminare il video e passare alla HomeView (6 secondi totali)
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    withAnimation {
                        splashFinita = true
                    }
                }
            }
        }
    }
}
