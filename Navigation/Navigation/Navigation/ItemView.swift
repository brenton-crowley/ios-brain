import CasePaths
import SwiftUI

struct ItemView: View {
    @State var item = Item(name: "", color: nil, status: .inStock(quantity: 1))

    var body: some View {
        Form {
            TextField.init("Name", text: $item.name)

            Picker(
                selection: $item.color,
                label: Text("Color"),
                content: {
                    Text("None")
                        .tag(Item.Color?.none)

                    ForEach(Item.Color.defaults, id: \.name) { color in
                        Text(color.name)
                            .tag(Optional(color))
                    }
                }
            )

            IfCaseLet($item.status, matches: /Item.Status.inStock) { $quantity in
                Section(header: Text("In stock")) {
                    Stepper("Quantity: \(quantity)", value: $quantity)
                    Button("Mark as sold out") { item.status = .outOfStock(isOnBackOrder: false) }
                }
            }

            IfCaseLet($item.status, matches: /Item.Status.outOfStock) { (isOnBackOrder: Binding<Bool>) in
                Section(header: Text("Out of stock")) {
                    Toggle("Is on back order", isOn: isOnBackOrder)
                    Button("Is back in stock!") { item.status = .inStock(quantity: 1) }
                }
            }
        }
    }
}

#Preview {
    ItemView()
}
