import CasePaths
import SwiftUI

/// Inspiration source: https://www.pointfree.co/episodes/ep161-swiftui-navigation-tabs-alerts-part-2

extension Binding {
    /// Creates a `Binding<Bool>` based on the wrapped value of some optional data not being nil.
    ///
    /// When the `Binding<Bool>` is set to false, then this will also set wrapped value to `nil`.
    ///
    /// - Returns: `false` if the wrapped value is equal to nil and `true` if the wrapped value is not nil.
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

extension View {
    /// `.alert()` overload that removes the dual source of truth for a data source and a bool.
    ///
    ///   T: is the data source
    ///
    /// - Parameters:
    ///   - title: Closure that injects the data source and defaults to an empty `Text("")` if `nil`.
    ///   - data: T that can be optional.
    ///   - actions: Closure that should define the button actions of the alert.
    ///   - message: Closure that includes the text of the message to display.
    /// - Returns: Call to alert view modifier.
    func alert<A: View, M: View, T>(
        title: (T) -> Text,
        presenting data: Binding<T?>,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        alert(
            data.wrappedValue.map(title) ?? Text(""),
            isPresented: data.isPresent(),
            presenting: data.wrappedValue,
            actions: actions,
            message: message
        )
    }

    func confirmationDialog<A: View, M: View, T>(
        title: (T) -> Text,
        presenting data: Binding<T?>,
        titleVisibility: Visibility = .automatic,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        confirmationDialog(
            data.wrappedValue.map(title) ?? Text(""),
            isPresented: data.isPresent(),
            titleVisibility: titleVisibility,
            presenting: data.wrappedValue,
            actions: actions,
            message: message
        )
    }
}

struct IfCaseLet<Enum, Case, Content>: View where Content: View {
    let binding: Binding<Enum>
    let casePath: AnyCasePath<Enum, Case>
    let content: (Binding<Case>) -> Content

    init(
        _ binding: Binding<Enum>,
        matches casePath: AnyCasePath<Enum, Case>,
        @ViewBuilder content: @escaping (Binding<Case>) -> Content
    ) {
        self.binding = binding
        self.casePath = casePath
        self.content = content
    }

    var body: some View {
        if let `case` = casePath.extract(from: binding.wrappedValue) {
            content(
                Binding(
                    get: { `case` },
                    set: { binding.wrappedValue = casePath.embed($0) }
                )
            )
        }
    }
}
