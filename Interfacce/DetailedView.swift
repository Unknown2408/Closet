import SwiftUI

// Dizionario dei colori
let uiColors: [String: Color] = [
    "WHITE": .white, "LIGHT GRAY": Color(white: 0.8), "GRAY": .gray, "DARK GRAY": Color(white: 0.2), "BLACK": .black,
    "RED": .red, "MAROON": Color(red: 0.5, green: 0, blue: 0), "ORANGE": .orange, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86), "YELLOW": .yellow,
    "GREEN": .green, "OLIVE": Color(red: 0.5, green: 0.5, blue: 0), "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5), "PURPLE": .purple,
    "PINK": .pink, "BROWN": .brown, "CYAN": .cyan, "TEAL": Color(red: 0, green: 0.5, blue: 0.5), "MAGENTA": Color(red: 1, green: 0, blue: 1)
]

struct DetailView: View {
    let cloth: Cloth
    var onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // 1. Menu in alto
            HStack {
                Spacer()
                Menu {
                    Button(action: { /* Modify */ }) {
                        Label("Modify", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {
                        onDelete()
                        dismiss()
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

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 2. Immagine
                    if let uiImage = UIImage(data: cloth.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .cornerRadius(12)
                    }

                    // 3. Info Prodotto (Brand e Tipo)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(cloth.brand)
                            .font(.title2.bold())
                        Text(cloth.type.rawValue)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // 4. Dettagli (Brand, Stagione, Colori)
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Brand")
                                .font(.headline)
                            Text(cloth.brand)
                                .foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Season")
                                .font(.headline)
                            Text(cloth.season.map { $0.rawValue }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }

                        // --- SEZIONE COLORI: TESTO + PALLINO ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colors")
                                .font(.headline)
                            
                            ForEach(cloth.coloreIndumentoRicerca, id: \.self) { coloreEnum in
                                HStack(spacing: 8) {
                                    // Prima il nome del colore
                                    Text(coloreEnum.rawValue.capitalized)
                                        .foregroundColor(.secondary)
                                    
                                    // Poi il pallino colorato
                                    Circle()
                                        .fill(uiColors[coloreEnum.rawValue] ?? Color.gray)
                                        .frame(width: 14, height: 14)
                                        .overlay(
                                            Circle().stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // 5. Pulsante Match
            Button(action: { /* Azione Match */ }) {
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
        .navigationTitle("Dettaglio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
