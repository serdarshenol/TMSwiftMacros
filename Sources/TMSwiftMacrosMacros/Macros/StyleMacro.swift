//
//  StyleMacro.swift
//  TMSwiftMacros
//
//  Created by Naoufal Medouri on 18/01/2024.
//  Copyright © 2024 Trackman. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum StyleMacro {}

// MARK: - MemberMacro
extension StyleMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let identifier = declaration.as(ProtocolDeclSyntax.self) else {
            throw CustomError.message("@Style can only be applied to protocol declarations.")
        }

        return [
            "associatedtype Body: View",
            "typealias Configuration = \(raw: identifier.name.text)Configuration",
            "@ViewBuilder func makeBody(configuration: Self.Configuration) -> Self.Body",
        ]
    }
}

// MARK: - PeerMacro
extension StyleMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let identifier = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }

        guard
            case .argumentList(let arguments) = node.arguments,
            arguments.count == 1,
            let subviewsNamesArgument = arguments.first?.expression
        else {
            throw CustomError.message("@Style macro expects one argument to be passed as `[String]`.")
        }

        let styleName = identifier.name.text
        let subviewsNames = toStringArray(expression: subviewsNamesArgument)

        return [
            configurationDeclarationWithSubViews(subviewsNames, styleName: styleName),
            defaultStyleDeclarationWithSubViews(subviewsNames, styleName: styleName),
            typeErasedStyleDeclaration(forStyle: styleName),
            styleEnvironmentKey(forStyle: styleName)
        ]
    }

    private static func configurationDeclarationWithSubViews(
        _ subviewsNames: [String],
        styleName: String
    ) -> DeclSyntax {
        var innerContentDeclarations = ""
        var properties = ""

        for subviewName in subviewsNames {
            // Inner declaration
            innerContentDeclarations.append(
                """
                public struct \(subviewName): View {
                    public var body: AnyView

                    public init<Content: View>(content: Content) {
                        body = AnyView(content)
                    }
                }
                """
            )
            
            // Property
            properties.append(
                "public var \(subviewName.withFirstCharacterLowercased): Self.\(subviewName)\n"
            )
        }

        return "public struct \(raw: styleName)Configuration {\(raw: innerContentDeclarations)\n\n\(raw: properties)}"
    }

    private static func defaultStyleDeclarationWithSubViews(
        _ subviewsNames: [String],
        styleName: String
    ) -> DeclSyntax {
        var configurationSubviews = ""
        for subviewsName in subviewsNames {
            configurationSubviews.append(
                "configuration.\(subviewsName.withFirstCharacterLowercased)\n"
            )
        }

        return
            """
            public struct Default\(raw: styleName): \(raw: styleName) {
                public init() {}

                public func makeBody(configuration: Configuration) -> some View {
                    VStack {\(raw: configurationSubviews)}
                }
            }
            """
    }

    private static func typeErasedStyleDeclaration(forStyle styleName: String) -> DeclSyntax {
        return """
            struct Any\(raw: styleName): \(raw: styleName) {
                private var _makeBody: (Configuration) -> AnyView

                init(style: some \(raw: styleName)) {
                    _makeBody = { configuration in
                        AnyView(style.makeBody(configuration: configuration))
                    }
                }

                func makeBody(configuration: Configuration) -> some View {
                    _makeBody(configuration)
                }
            }
            """
    }

    private static func styleEnvironmentKey(forStyle styleName: String) -> DeclSyntax {
        return """
            struct \(raw: styleName)Key: EnvironmentKey {
                static let defaultValue = Any\(raw: styleName)(style: Default\(raw: styleName)())
            }
            """
    }

    private static func toStringArray(expression: ExprSyntax) -> [String] {
        guard expression.description.contains(where: { char in char == "[" }) else {
            return []
        }

        let arrayExpression = expression.description
        let stringsArray = arrayExpression.dropFirst().dropLast().split(separator: ",")
        var strings = [String]()

        for string in stringsArray {
            strings.append(String(string).replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces))
        }

        return strings
    }
}
