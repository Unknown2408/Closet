import SwiftUI

struct ContentView: View {
    // Gestisce lo stato dell'animazione iniziale
    @State private var splashFinita = false
    
    // Inizializziamo qui il manager globale dell'app
    @State private var manager = ClosetManager()

    var body: some View {
        ZStack {
            if !splashFinita {
                // 1. SCHERMATA DI SPLASH (Caricamento)
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack {
                        Image("LogoApp") // Assicurati che il nome corrisponda nei tuoi Assets
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        
                        Text("Welcome to your Closet")
                            .font(.system(size: 25, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }
                .transition(.opacity) // Prepara la dissolvenza in uscita
                
            } else {
                // 2. HOMEVIEW (App vera e propria)
                // Passiamo "" (stringa vuota) come nome, così la tua HomeView scriverà automaticamente "My Closet"
                HomeView(nome: "")
                    .environment(manager) // Passiamo il manager a tutta l'app
                    .transition(.opacity) // Prepara la dissolvenza in entrata
            }
        }
        // Applica l'animazione di dissolvenza (1.5 secondi) a tutto lo ZStack
        .animation(.easeInOut(duration: 1.5), value: splashFinita)
        .onAppear {
            // Avvia un timer appena l'app si apre
            // Dopo 2.5 secondi, cambia lo stato e innesca la dissolvenza
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                splashFinita = true
            }
        }
    }
}

#Preview {
    ContentView()
}
