import SwiftUI

@main
struct ClosetApp: App {
    @State private var splashFinita: Bool = false
    @State private var loginEffettuato: Bool = false
    @State private var videoOpacita: Double = 0.0 // Per la dissolvenza in entrata
    @State private var nomeUtente: String = ""
    @State private var manager = ClosetManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Sfondo nero universale
                Color.black.ignoresSafeArea()
                
                if !splashFinita {
                    CustomVideoPlayer(videoName: "ClosetIntro", videoExtension: "mp4")
                        .ignoresSafeArea()
                        .opacity(videoOpacita)
                        .transition(.opacity)
                        .onAppear {
                            // Dissolvenza in ENTRATA
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeIn(duration: 1.5)) {
                                    videoOpacita = 1.0
                                }
                            }
                        }
                }  else {
                    HomeView(nome: nomeUtente)
                        .environment(manager)
                        .transition(.opacity)
                }
            }
            // Gestione globale delle transizioni (Dissolvenza in USCITA)
            .animation(.easeInOut(duration: 1.5), value: splashFinita)
            .animation(.easeInOut(duration: 1.5), value: loginEffettuato)
            .onAppear {
                // Timer per passare alla LoginView (6 secondi totali)
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    withAnimation {
                        splashFinita = true
                    }
                }
            }
        }
    }
}
