//
//  DetailedView.swift
//  Closet
//
//  Created by Nitharsan on 19/02/26.
//

import SwiftUI

struct DetailView: View {
    let cloth: Cloth
    
    var body: some View {
        VStack {
            // 1. Menu con tre puntini in alto a destra
            HStack {
                Spacer()
                Menu {
                    Button(action: {
                        // Azione per modificare
                    }) {
                        Label("Modify", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        // Azione per eliminare
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // 2. Spazio per l'immagine (che caricherai dopo)
            Spacer().frame(height: 250)

            // 3. Info Prodotto allineate a sinistra
            VStack(alignment: .leading, spacing: 8) {
                Text(cloth.brand)
                    .font(.title2)
                    .bold()
                
                Text("T-shirt")
                    .foregroundColor(.secondary)
                
                Divider().padding(.vertical, 10)
                
                HStack {
                    Text("Description")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            Spacer() // Spinge il tasto Match verso il basso

            // 4. Pulsante Match
            Button(action: {
                // Azione Match
            }) {
                Text("Match")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 10)
        }
        // I modificatori devono stare qui, dopo la chiusura della VStack
        .navigationTitle("Dettaglio")
        .navigationBarTitleDisplayMode(.inline)
    }
}


