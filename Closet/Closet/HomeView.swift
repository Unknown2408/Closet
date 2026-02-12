//
//  HomeView.swift
//  Closet
//
//  Created by Nitharsan on 11/02/26.
//

import SwiftUI

struct HomeView: View {
    var nome: String // Riceve il nome dal login
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header: Welcome + Nome
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome,")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundColor(.gray)
                    
                    Text(nome)
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
                
                Spacer()
                
                // Pulsanti Funzioni
                HStack(spacing: 25) {
                    Spacer()
                    
                    // Lente di ingrandimento
                    CircleButton(icon: "magnifyingglass") {
                        print("Cerca")
                    }
                    
                    // Più (per aggiungere)
                    CircleButton(icon: "plus", isMain: true) {
                        print("Aggiungi")
                    }
                    
                    // Cestino
                    CircleButton(icon: "trash") {
                        print("Elimina")
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// Sottovista per i pulsanti rotondi
struct CircleButton: View {
    let icon: String
    var isMain: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1)) // Sfondo leggermente visibile
                    .frame(width: isMain ? 80 : 65, height: isMain ? 80 : 65)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: isMain ? 30 : 22, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
