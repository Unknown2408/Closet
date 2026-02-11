//
//  LoginView.swift
//  Closet
//
//  Created by Emanuele Restivo on 11/02/26.
//

import SwiftUI

struct LoginView: View {
    
    @State private var nome: String = ""
    @State private var cognome: String = ""
    
    var body: some View {
        ZStack {
            
            VStack {
                //Immagine Logo
                Image("LogoApp")
                    .resizable()
                    .scaledToFit()
                
                
                //Scritta
                Text ("Welcome in your Closet!")
                    .font(.system(size:25,weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .padding(19)
                
            }
            .padding(.bottom, 360)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Espande l'HStack a tutto schermo
            .background(Color.black)
            .ignoresSafeArea()
            
            //Registrazione
            
            Text("Enter your name and your surname")
                .padding(.top, 120)
                .font(.system(size:18,weight: .bold, design: .serif))
                .foregroundColor(.white)
                            
            VStack(spacing: 15) {
                // Campo Nome
                
                TextField("Name", text: $nome)
                    .padding()
                    .background(Color.white.opacity(0.1)) // Sfondo grigio scuro semitrasparente
                    .cornerRadius(10)
                    .foregroundColor(.white) // Colore del testo che scrivi
                
                TextField("Surname", text: $cognome)
                    .padding()
                    .background(Color.white.opacity(0.1)) // Sfondo grigio scuro semitrasparente
                    .cornerRadius(10)
                    .foregroundColor(.white) // Colore del testo che scrivi
                    
            }
            .padding(.horizontal, 40) // Distanza dai bordi dello schermo
            .padding(.top, 300)
            
        
        }
        
    }
}

#Preview {
    LoginView()
}
