import SwiftUI
import UIKit

struct EditOutfitView: View {
    @Environment(ClosetManager.self) var closetManager
    @Environment(\.dismiss) var dismiss
    
    let outfitId: UUID
    
    @State private var outfitName: String = ""
    @State private var selectedItems: [Cloth] = []
    
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
                    
                    VStack(spacing: 15) {
                        ForEach(Position.allCases) { position in
                            VStack(spacing: 15) {
                                OutfitSlotRow(
                                    position: position,
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
            .navigationTitle("Edit Outfit")
            .navigationBarTitleDisplayMode(.inline)
            
            .onAppear {
                if let outfit = closetManager.outfits.first(where: { $0.id == outfitId }) {
                    outfitName = outfit.outfitName
                    selectedItems = closetManager.items(for: outfit)
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let finalName = outfitName.trimmingCharacters(in: .whitespaces).isEmpty ? "Edited Outfit" : outfitName
                        let itemsIds = selectedItems.map { $0.id }
                        closetManager.updateOutfit(id: outfitId, newName: finalName, newItems: itemsIds)
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
