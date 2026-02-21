import SwiftUI
import Combine

/// Zebra Shop view for purchasing accessories
struct ZebraShopView: View {
    let childId: String
    let childPoints: Int
    let onDismiss: () -> Void

    @StateObject private var shopRepository = ZebraShopRepository()
    @State private var accessories: [Accessory] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedAccessory: Accessory?
    @State private var showingPurchaseAlert = false
    
    // Combine cancellables
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if isLoading {
                    LoadingView(message: "Winkel laden...")
                } else {
                    contentView
                }
            }
            .navigationTitle("🦓 Zebra Winkel")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sluiten") {
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(childPoints)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
            .alert("Accessoire kopen", isPresented: $showingPurchaseAlert) {
                Button("Annuleren", role: .cancel) { }
                Button("Kopen") {
                    purchaseSelectedAccessory()
                }
            } message: {
                if let accessory = selectedAccessory {
                    Text("Wil je \"\(accessory.name)\" kopen voor \(accessory.price) punten?")
                }
            }
            .alert("Fout", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
        .onAppear {
            loadAccessories()
        }
    }

    // MARK: - Content View
    private var contentView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(accessories) { accessory in
                    AccessoryCardView(
                        accessory: accessory,
                        childPoints: childPoints,
                        onPurchase: {
                            selectedAccessory = accessory
                            showingPurchaseAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }

    // MARK: - Private Methods
    private func loadAccessories() {
        isLoading = true

        shopRepository.getAccessories()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    switch completion {
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                },
                receiveValue: { loadedAccessories in
                    accessories = loadedAccessories
                }
            )
            .store(in: &cancellables) // ✅ Gebruik hier de juiste Set<AnyCancellable>
    }

    private func purchaseSelectedAccessory() {
        guard let accessory = selectedAccessory else { return }

        shopRepository.purchaseAccessory(accessoryId: accessory.id, childId: childId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    onDismiss() // Close shop after purchase
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }

                selectedAccessory = nil
            }
        }
    }
}

// MARK: - Accessory Card View
struct AccessoryCardView: View {
    let accessory: Accessory
    let childPoints: Int
    let onPurchase: () -> Void

    @State private var isAnimating = false

    private var canAfford: Bool {
        childPoints >= accessory.price
    }

    var body: some View {
        VStack(spacing: 12) {
            // Emoji
            Text(accessory.emoji)
                .font(.system(size: 50))
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)

            // Name
            Text(accessory.name)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Description
            if !accessory.description.isEmpty {
                Text(accessory.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            // Price and Button
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)

                    Text("\(accessory.price)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.yellow.opacity(0.2))
                )

                Button(action: {
                    if canAfford {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isAnimating = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onPurchase()
                            isAnimating = false
                        }
                    }
                }) {
                    Text(canAfford ? "Kopen" : "Te duur")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(canAfford ? Color.blue : Color.gray)
                        )
                }
                .disabled(!canAfford)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
struct ZebraShopView_Previews: PreviewProvider {
    static var previews: some View {
        ZebraShopView(
            childId: "child1",
            childPoints: 75,
            onDismiss: {}
        )
    }
}
