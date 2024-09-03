//
//  RegisterStyle.swift
//  TMSwiftMacros
//
//  Created by Naoufal Medouri on 24/01/2024.
//  Copyright © 2024 Trackman. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum RegisterStyleMacro {}

// MARK: - MemberMacro
extension RegisterStyleMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard (declaration.as(ExtensionDeclSyntax.self) != nil) else {
            throw CustomError.message("@RegisterStyle can only be applied to extension declarations.")
        }

        guard
            case .argumentList(let arguments) = node.arguments,
            arguments.count == 1,
            let styleNameArgument = arguments.first?.expression
        else {
            throw CustomError.message("@RegisterStyle macro expects one argument to be passed as `String`.")
        }

        let styleName = styleNameArgument.description.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
        let camelcasedStyleName = styleName.withFirstCharacterLowercased

        let getter = "get { self[\(styleName)Key.self] }"
        let setter = "set { self[\(styleName)Key.self] = newValue }"

        return [
            "var \(raw: camelcasedStyleName): Any\(raw: styleName) { \(raw: getter)\n\(raw: setter)}"
        ]
    }
}
