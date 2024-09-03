//
//  TMSwiftMacros.swift
//  TMSwiftMacros
//
//  Created by Naoufal Medouri on 18/01/2024.
//  Copyright © 2024 Trackman. All rights reserved.
//


// MARK: - Style Macro
/// A macro that generates the boilerplate code necessary to setup a SwiftUI UI component style.
///
/// Other than adding the declaration of the necessary members to the protocol it is attached to,
/// the macro generates the configuration type, as well as convenience types that make registering
/// the style in the `Environment` easier. The macro uses the list of the sub-views passed
/// in as argument to generate the structure of the configuration type.
///
/// For example,
///
/// ```swift
/// @Style(subViews: ["Title", "Icon"])
/// public protocol MyStyle {}
/// ```
///
/// expands to the following code:
///
/// ```swift
/// @Style(subViews: ["Title", "Icon"])
/// public protocol MyStyle {
///     associatedtype Body: View
///
///     typealias Configuration = MyStyleConfiguration
///
///     @ViewBuilder func makeBody(configuration: Self.Configuration) -> Self.Body
/// }
///
/// public struct MyStyleConfiguration {
///     public struct Title: View {
///         public var body: AnyView
///
///         public init<Content: View>(content: Content) {
///             body = AnyView(content)
///         }
///     }
///     public struct Icon: View {
///         public var body: AnyView
///
///         public init<Content: View>(content: Content) {
///             body = AnyView(content)
///         }
///     }
///
///     public var title: Self.Title
///     public var icon: Self.Icon
/// }
///
/// public struct DefaultMyStyle: MyStyle {
///     public init() {
///     }
///
///     public func makeBody(configuration: Configuration) -> some View {
///         VStack {
///             configuration.title
///             configuration.icon
///         }
///     }
/// }
///
/// struct AnyMyStyle: MyStyle {
///     private var _makeBody: (Configuration) -> AnyView
///
///     init(style: some MyStyle) {
///         _makeBody = { configuration in
///             AnyView(style.makeBody(configuration: configuration))
///         }
///     }
///
///     func makeBody(configuration: Configuration) -> some View {
///         _makeBody(configuration)
///     }
/// }
///
/// struct MyStyleKey: EnvironmentKey {
///     static let defaultValue = AnyMyStyle(style: DefaultMyStyle())
/// }
/// ```
///
/// - Important: The UI component that is going to use the generated style code, needs to be generic over
/// the same number of sub-views passed to the macro, respecting both the names and the order.
/// - Note: You can use the `@UIComponent` macro to generate the necessary members of the component.
///
@attached(member, names: named(Body), named(Configuration), named(makeBody), arbitrary)
@attached(peer, names: suffixed(Configuration), prefixed(`Any`), prefixed(Default), suffixed(Key))
public macro Style(subViews: [String]) = #externalMacro(module: "TMSwiftMacrosMacros", type: "StyleMacro")

/// A macro that adds a property with a setter and a getter to store and read the given style
/// from a storage that accepts a `Type` as key.
///
/// For example,
///
/// ```swift
/// @RegisterStyle("MyComponentStyle")
/// extension EnvironmentValues {}
/// ```
/// expands to:
/// ```swift
/// @RegisterStyle("MyComponentStyle")
/// extension EnvironmentValues {
///     var myComponentStyle: AnyMyComponentStyle {
///         get {
///             self[MyComponentStyleKey.self]
///         }
///         set {
///             self[MyComponentStyleKey.self] = newValue
///         }
///     }
/// }
/// ```
///
@attached(member, names: arbitrary)
public macro RegisterStyle(_: String) = #externalMacro(module: "TMSwiftMacrosMacros", type: "RegisterStyleMacro")

/// A macro that extends the `View` protocol with a modifier declaration as a convenience
/// for applying the given style to a view.
///
/// For example,
///
/// ```swift
/// @ConvenienceModifierForStyle("MyComponentStyle")
/// extension View { }
/// ```
/// expands to:
///
/// ```swift
/// @ConvenienceModifierForStyle("MyComponentStyle")
/// extension View {
///     public func myComponentStyle(_ style: some MyComponentStyle) -> some View {
///         environment(\.myComponentStyle, AnyMyComponentStyle(style: style))
///     }
/// }
/// ```
/// - Important: Both the given style and its corresponding type-erased style need to exist before applying the macro.
/// Use eventually the `@Style` macro to generate them both.
///
@attached(member, names: arbitrary)
public macro ConvenienceModifierForStyle(_: String) = #externalMacro(module: "TMSwiftMacrosMacros", type: "ConvenienceModifierForStyleMacro")

/// A macro that adds the necessary members declarations to adopt a predefined style and configuration.
///
/// The macro expects that the style has already been created and registered in the `Environment`,
/// and a configuration type that declares sub-views that match the generic views of the components
/// both in name, order, and number.
///
/// For example,
///
/// ```swift
/// @UIComponent
/// public struct MyComponent<Title: View, Icon: View>: View { }
/// ```
/// expands to the following code:
///
/// ```swift
/// @UIComponent
/// public struct MyComponent<Title: View, Icon: View>: View {
///     @Environment(\.myComponentStyle) var style
///
///     typealias Configuration = MyComponentStyleConfiguration
///
///     public let title: () -> Title
///
///     public let icon: () -> Icon
///
///     public var body: some View {
///         style.makeBody(configuration: Configuration(title:Configuration.Title(content: title()), icon: Configuration.Icon(content: icon())))
///     }
/// }
/// ```
///
/// In this example, it is expected that the style has been registered with the key `myComponentStyle`,
/// and that the configuration type has `MyComponentStyleConfiguration` as name.
///
/// > You can use the `@Style` macro to generate the style and configuration, and
/// > the `@RegisterStyle` macro to register the style. For example, the following code will
/// > both generate the style and configuration, and register the style:
/// >
/// > ```swift
/// > @Style(subViews: ["Title", "Icon"])
/// > public protocol MyComponentStyle {}
/// >
/// > @RegisterStyle("MyComponentStyle")
/// > extension EnvironmentValues {}
/// > ```
///
@attached(member, names: named(body), named(style), arbitrary)
public macro UIComponent() = #externalMacro(module: "TMSwiftMacrosMacros", type: "UIComponentMacro")
