//
//  ContentView.swift
//  Navigation
//
//  Created by Brent Crowley on 27/1/2025.
//

import SwiftUI

enum TabOption {
    case one, two, three, inventory
}

class AppViewModel: ObservableObject {
    @Published var inventoryViewModel: InventoryViewModel
    @Published var selectedTab: TabOption

    init(selectedTab: TabOption = .one, inventoryViewModel: InventoryViewModel = .init()) {
        self.selectedTab = selectedTab
        self.inventoryViewModel = inventoryViewModel
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        TabView(
            selection: $viewModel.selectedTab) {
                Tab(
                    "One",
                    systemImage: "bell",
                    value: TabOption.one,
                    content: { Color.red }
                )

                Tab(
                    "Inventory",
                    systemImage: "list.clipboard",
                    value: TabOption.inventory,
                    content: { InventoryView(viewModel: viewModel.inventoryViewModel) }
                )

                Tab(
                    "Three",
                    systemImage: "wrench",
                    value: TabOption.three,
                    content: { Color.blue }
                )
            }
    }
}

#Preview {
    ContentView(
        viewModel: .init(
            selectedTab: .inventory,
            inventoryViewModel: .init(
                inventory: [
                    Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20)),
                    Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true)),
                    Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false))
                ]
            )
        )
    )
}
