import SwiftUI
import UIKit

struct OutfitDetailView: View {
    // Il nostro manager
    @Environment(ClosetManager.self) var closetManager
    // Per tornare indietro automaticamente quando cancelliamo l'outfit
    @Environment(\.dismiss) var dismiss
    
    // Passiamo l'ID anziché tutto l'outfit. È più sicuro per i dati dinamici!
    let outfitId: UUID
    
    // Variabile per mostrare l'avviso di eliminazione
    @State private var showingDeleteAlert = false
    
    var body: some View {
        // Cerchiamo l'outfit in tempo reale usando l'ID
        if let outfit = closetManager.outfits.first(where: { $0.id == outfitId }) {
            
            // Trasformiamo gli UUID nei capi veri
            let clothes = closetManager.items(for: outfit)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. INTESTAZIONE (Nome e Data)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(outfit.outfitName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Formattiamo la data in modo leggibile (es. "12 Ott 2024, 15:30")
                        Text("Creato il \(outfit.dateCreated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 2. GRIGLIA DEI VESTITI
                    Text("Capi in questo outfit (\(clothes.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(clothes) { cloth in
                            VStack {
                                // Immagine del capo
                                if let uiImage = UIImage(data: cloth.image) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 160)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: .black.opacity(0.1), radius: 3)
                                } else {
                                    Image(systemName: "tshirt")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .frame(height: 160)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // Etichetta sotto il capo
                                Text(cloth.type.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            // 3. MENU IN ALTO A DESTRA (Elimina / Modifica)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // Tasto Modifica (Per ora stampa in console, lo faremo dopo)
                        Button {
                            print("Apri schermata di modifica")
                        } label: {
                            Label("Modifica", systemImage: "pencil")
                        }
                        
                        // Tasto Elimina (Rosso distruttivo)
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Elimina Outfit", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            // 4. ALERT DI CONFERMA ELIMINAZIONE
            .alert("Elimina Outfit", isPresented: $showingDeleteAlert) {
                Button("Annulla", role: .cancel) { }
                Button("Elimina", role: .destructive) {
                    closetManager.deleteOutfit(id: outfit.id)
                    dismiss() // Chiude la vista di dettaglio e torna alla griglia!
                }
            } message: {
                Text("Sei sicuro di voler eliminare questo abbinamento? I vestiti rimarranno comunque nel tuo armadio.")
            }
            
        } else {
            // Se non trova l'outfit (es. appena eliminato)
            Text("Outfit non trovato.")
        }
    }
}
