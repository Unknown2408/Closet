import SwiftUI

// 1. IL DIZIONARIO DEI COLORI
private let uiColorsDict: [String: Color] = [
    "WHITE": .white, "LIGHT GRAY": Color(white: 0.8), "GRAY": .gray, "DARK GRAY": Color(white: 0.2), "BLACK": .black,
    "RED": .red, "MAROON": Color(red: 0.5, green: 0, blue: 0), "ORANGE": .orange, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86), "YELLOW": .yellow,
    "GREEN": .green, "OLIVE": Color(red: 0.5, green: 0.5, blue: 0), "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5), "PURPLE": .purple,
    "PINK": .pink, "BROWN": .brown, "CYAN": .cyan, "TEAL": Color(red: 0, green: 0.5, blue: 0.5), "MAGENTA": Color(red: 1, green: 0, blue: 1)
]

struct DetailedView: View {
    let cloth: Cloth
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingMatchesSheet = false
    @State private var showingDeleteConfirm = false
    
    var currentCloth: Cloth {
        manager.inventory.first(where: { $0.id == cloth.id }) ?? cloth
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. NOME E BRAND
                    VStack(alignment: .leading, spacing: 5) {
                        Text(currentCloth.name)
                            .font(.title.bold())
                        Text(currentCloth.brand.uppercased())
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 2. BOX IMMAGINE
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)

                        if let uiImage = UIImage(data: currentCloth.image) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                        } else {
                            Image(systemName: "tshirt.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(60)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // 3. DETTAGLI (Style, Season, Colors)
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Style").font(.headline)
                            Text(currentCloth.style.map { $0.rawValue }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Season").font(.headline)
                            Text(currentCloth.season.map { $0.rawValue }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colors").font(.headline)
                            ForEach(currentCloth.coloreIndumentoRicerca, id: \.self) { coloreEnum in
                                HStack(spacing: 8) {
                                    Text(coloreEnum.rawValue.capitalized).foregroundColor(.secondary)
                                    Circle()
                                        .fill(uiColorsDict[coloreEnum.rawValue.uppercased()] ?? Color.gray)
                                        .frame(width: 14, height: 14)
                                        .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Pulsante Match
            Button(action: { showingMatchesSheet = true }) {
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        manager.toggleFavorite(ofItemWithID: currentCloth.id)
                    }
                }) {
                    Image(systemName: currentCloth.favourite ? "heart.fill" : "heart")
                        .foregroundColor(currentCloth.favourite ? .red : .black)
                }
                
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { showingDeleteConfirm = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) { NewItemView(itemToEdit: currentCloth) }
        .sheet(isPresented: $showingMatchesSheet) { MatchCreationSheet(anchorCloth: currentCloth) }
        .alert("Delete Item", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                manager.removeItem(withID: currentCloth.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this item? This action cannot be undone.")
        }
    }
}

// MARK: - Modale Abbinamenti (SISTEMA A SLOT)
struct MatchCreationSheet: View {
    let anchorCloth: Cloth
    @Environment(ClosetManager.self) private var closetManager
    @Environment(\.dismiss) var dismiss
    
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
                    
                    Text("Complete the look")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 5) {
                        ForEach(Position.allCases) { position in
                            VStack(spacing: 15) {
                                let itemsForSlot = selectedItems.filter { $0.position == position }
                                
                                OutfitSlotRow(
                                    position: position,
                                    items: itemsForSlot,
                                    onAdd: { activeSlotPosition = position },
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
            .navigationTitle("Build Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let name = outfitName.isEmpty ? "Match Outfit" : outfitName
                        closetManager.addOutfit(name: name, items: selectedItems.map { $0.id })
                        dismiss()
                    }
                    .disabled(selectedItems.count < 2)
                }
            }
            .sheet(item: $activeSlotPosition) { position in
                SlotSelectionView(
                    position: position,
                    outfitItems: $selectedItems
                )
            }
            .onAppear {
                selectedItems = [anchorCloth]
            }
        }
    }
}
