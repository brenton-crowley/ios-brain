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

            switch item.status {
            case let .inStock(quantity):
                Section(header: Text("In stock")) {
                    Stepper.init(
                        "Quantity: \(quantity)",
                        value: .init(
                            get: { quantity },
                            set: { item.status = .inStock(quantity: $0)}
                        )
                    )


                    Button("Mark as sold out") {
                        item.status = .outOfStock(isOnBackOrder: false)
                    }
                }

            case let .outOfStock(isOnBackOrder):
                Section(header: Text("Out of stock")) {
                    Toggle(
                        "Is on back order",
                        isOn: .init(
                            get: { isOnBackOrder },
                            set: { item.status = .outOfStock(isOnBackOrder: $0) }
                        )
                    )

                    Button("Is back in stock!") {
                        item.status = .inStock(quantity: 1)
                    }
                }
            }
        }
    }
}

#Preview {
    ItemView()
}
