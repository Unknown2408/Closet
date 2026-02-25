import SwiftUI

struct CreateOutfitView: View {
    @Environment(ClosetManager.self) var closetManager
    @Environment(\.dismiss) var dismiss
    
    @State private var outfitName: String = ""
    @State private var selectedItems: [Cloth] = []
    
    // GESTIONE DEGLI SLOT
    @State private var activeSlotPosition: Position? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    OutfitNameSection(outfitName: $outfitName)
                        .padding(.top)
                    
                    Divider().padding(.horizontal)
                    
                    Text("Build your look")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    
                    // 🔥 Ciclo semplificato per non far esplodere il compilatore SwiftUI
                    VStack(spacing: 15) {
                        ForEach(Position.allCases) { position in
                            VStack(spacing: 15) {
                                OutfitSlotRow(
                                    position: position,
                                    // Filtro i capi direttamente qui
                                    items: selectedItems.filter { $0.position == position },
                                    onAdd: {
                                        activeSlotPosition = position
                                    },
                                    onRemove: { itemToRemove in
                                        withAnimation {
                                            selectedItems.removeAll { $0.id == itemToRemove.id }
                                        }
                                    }
                                )
                                
                                if position != Position.allCases.last {
                                    Divider().padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("New Outfit")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let name = outfitName.isEmpty ? "New Outfit" : outfitName
                        closetManager.addOutfit(name: name, items: selectedItems.map { $0.id })
                        dismiss()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
            .sheet(item: $activeSlotPosition) { position in
                SlotSelectionView(
                    position: position,
                    outfitItems: $selectedItems
                )
            }
        }
    }
}
