import SwiftUI

struct LoginView: View {
    @Binding var loginEffettuato: Bool
    @Binding var nome: String
    @State private var cognome: String = ""
    
    var isFormValid: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Image("LogoApp")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                Text("Welcome in your Closet!")
                    .font(.system(size: 25, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                Spacer().frame(height: 40)
                
                VStack(spacing: 15) {
                    TextField("", text: $nome, prompt: Text("Nickname").foregroundColor(.gray.opacity(0.6)))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                    // NUOVO: Pulsante Skip "Forse più tardi.."
                    Button(action: {
                        withAnimation {
                            nome = "" // Azzera il nome in modo esplicito
                            loginEffettuato = true
                        }
                    }) {
                        Text("Forse più tardi..")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.7))
                            .underline()
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    withAnimation {
                        loginEffettuato = true
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(isFormValid ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.white : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.top, 30)
                .disabled(!isFormValid)
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}
