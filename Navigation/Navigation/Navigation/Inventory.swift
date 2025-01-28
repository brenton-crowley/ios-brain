import CasePaths
import CasePathsCore
import IdentifiedCollections
import SwiftUI

struct Item: Equatable, Identifiable {
    let id = UUID()
    var name: String
    var color: Color?
    var status: Status
    //  var quantity: Int
    //  var isOnBackOrder: Bool

    @CasePathable
    enum Status: Equatable, CasePathable {        
        case inStock(quantity: Int)
        case outOfStock(isOnBackOrder: Bool)

        var isInStock: Bool {
            guard case .inStock = self else { return false }
            return true
        }
    }

    struct Color: Equatable, Hashable {
        var name: String
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        static var defaults: [Self] = [
            .red,
            .green,
            .blue,
            .black,
            .yellow,
            .white,
        ]

        static let red = Self(name: "Red", red: 1)
        static let green = Self(name: "Green", green: 1)
        static let blue = Self(name: "Blue", blue: 1)
        static let black = Self(name: "Black")
        static let yellow = Self(name: "Yellow", red: 1, green: 1)
        static let white = Self(name: "White", red: 1, green: 1, blue: 1)

        var swiftUIColor: SwiftUI.Color {
            .init(red: self.red, green: self.green, blue: self.blue)
        }
    }
}

class InventoryViewModel: ObservableObject {
    @Published var inventory: IdentifiedArrayOf<Item>
    @Published var itemToDelete: Item?
    @Published var itemToAdd: Item?

    init(
        inventory: IdentifiedArrayOf<Item> = [],
        itemToDelete: Item? = nil,
        itemToAdd: Item? = nil
    ) {
        self.inventory = inventory
        self.itemToDelete = itemToDelete
        self.itemToAdd = itemToAdd
    }

    func delete(item: Item) {
        withAnimation {
            // self.inventory.removeAll(where: { $0.id == item.id })
            _ = inventory.remove(id: item.id)
        }
    }

    func deleteButtonTapped(item: Item) {
        itemToDelete = item
    }
}

struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel

    var body: some View {
        List {
            ForEach(self.viewModel.inventory) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)

                        switch item.status {
                        case let .inStock(quantity):
                            Text("In stock: \(quantity)")
                        case let .outOfStock(isOnBackOrder):
                            Text("Out of stock" + (isOnBackOrder ? ": on back order" : ""))
                        }
                    }

                    Spacer()

                    if let color = item.color {
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(color.swiftUIColor)
                            .border(Color.black, width: 1)
                    }

                    Button(
                        action: {
                            self.viewModel.deleteButtonTapped(item: item)
                        }
                    ) {
                        Image(systemName: "trash.fill")
                    }
                    .padding(.leading)
                }
                .buttonStyle(.plain)
                .foregroundColor(item.status.isInStock ? nil : Color.gray)
            }
        }
        .confirmationDialog(
            title: { Text($0.name) },
            presenting: $viewModel.itemToDelete,
            titleVisibility: .visible,
            actions: { item in
                Button(
                    role: .destructive,
                    action: { viewModel.delete(item: item) },
                    label: { Text("Delete") }
                )
            },
            message: { Text("Are you sure you want to delete \($0.name)?") }
        )
        .toolbar {
            ToolbarItem.init(placement: .primaryAction) {
                Button(
                    "",
                    systemImage: "plus",
                    action: { viewModel.itemToAdd = .init(name: "", color: .black, status: .inStock(quantity: 1)) }
                )
            }
        }
        .navigationTitle("Inventory")
        .sheet(
            item: $viewModel.itemToAdd,
            onDismiss: {},
            content: { item in
                NavigationView { ItemView(item: item) }
            }
        )
        // .alert(
        //     title: { Text($0.name) },
        //     presenting: $viewModel.itemToDelete,
        //     actions: { item in
        //         Button(
        //             role: .destructive,
        //             action: { viewModel.delete(item: item) },
        //             label: { Text("Delete") }
        //         )
        //     },
        //     message: { Text("Are you sure you want to delete \($0.name)?") }
        // )
        // .alert(
        //     viewModel.itemToDelete?.name ?? "Delete",
        //     isPresented: $viewModel.itemToDelete.isPresent(),
        //     presenting: viewModel.itemToDelete,
        //     actions: { item in
        //         Button(
        //             role: .destructive,
        //             action: { item.map { viewModel.delete(item: $0) } },
        //             label: { Text("Delete") }
        //         )
        //     },
        //     message: { item in
        //         Text("Are you sure you want to delete \(item?.name ?? "this item")?")
        //     }
        // )
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        let keyboard = Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
        NavigationView {
            InventoryView(
                viewModel: .init(
                    inventory: [
                        keyboard,
                        Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20)),
                        Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true)),
                        Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false)),
                    ],
                    itemToDelete: nil
                )
            )
        }

    }
}
