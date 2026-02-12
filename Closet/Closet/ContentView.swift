//
//  ContentView.swift
//  Closet
//
//  Created by Nitharsan on 10/02/26.
//
//

import SwiftUI

struct ContentView: View {
    @Binding var nome: String
    @State private var cognome: String = ""
    
    var isFormValid: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty &&
        !cognome.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack { // Necessario per il passaggio tra file
            VStack(spacing: 20) {
                TextField("Nome", text: $nome)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                TextField("Cognome", text: $cognome)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                // Il NavigationLink punta alla struct HomeView
                NavigationLink(destination: HomeView(nome: nome)) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.white : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Next")
        }
    }
}
