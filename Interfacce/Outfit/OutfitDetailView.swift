import SwiftUI
import UIKit

struct OutfitDetailView: View {
    @Environment(ClosetManager.self) var closetManager
    @Environment(\.dismiss) var dismiss
    
    let outfitId: UUID
    @State private var showingDeleteAlert = false
    
    // 1. NUOVA VARIABILE: Controlla se il foglio di modifica è aperto
    @State private var isShowingEditSheet = false
    
    var body: some View {
        if let outfit = closetManager.outfits.first(where: { $0.id == outfitId }) {
            
            let clothes = closetManager.items(for: outfit)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. INTESTAZIONE (Nome e Data)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(outfit.outfitName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Created on \(outfit.dateCreated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 2. GRIGLIA DEI VESTITI
                    Text("Items in this outfit (\(clothes.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(clothes) { cloth in
                            VStack {
                                // 🔥 MODIFICA QUI: Usiamo OptimizedClothImage
                                OptimizedClothImage(imageData: cloth.image, targetSize: CGSize(width: 300, height: 300))
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.1), radius: 3)
                                
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
            
            // 3. MENU IN ALTO A DESTRA (Aggiunto Cuore + Elimina/Modifica)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    
                    // Pulsante Cuore
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        withAnimation {
                            closetManager.toggleFavorite(ofOutfitWithID: outfitId)
                        }
                    }) {
                        // Leggiamo il dato in tempo reale direttamente dal manager
                        let isFav = closetManager.outfits.first(where: { $0.id == outfitId })?.favourite ?? false
                        
                        Image(systemName: isFav ? "heart.fill" : "heart")
                            .foregroundColor(.black)
                    }
                    
                    Menu {
                        // 2. AZIONE MODIFICATA: Ora apre la modale di modifica!
                        Button {
                            isShowingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Outfit", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Outfit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    closetManager.deleteOutfit(id: outfitId) // Usiamo direttamente l'ID
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this outfit? The clothes will still remain in your closet.")
            }
            // 3. IL FOGLIO CHE CARICA LA SCHERMATA DI MODIFICA
            .sheet(isPresented: $isShowingEditSheet) {
                // Passiamo l'ID alla view che abbiamo creato prima
                EditOutfitView(outfitId: outfitId)
            }
            
        } else {
            Text("Outfit not found.")
        }
    }
}
