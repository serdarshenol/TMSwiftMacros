//
//  ConvenienceModifierForStyle.swift
//  TMSwiftMacros
//
//
//  Created by Naoufal Medouri on 24/01/2024.
//  Copyright © 2024 Trackman. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum ConvenienceModifierForStyleMacro {}

// MARK: - MemberMacro
extension ConvenienceModifierForStyleMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(ExtensionDeclSyntax.self) else {
            throw CustomError.message("@ConvenienceModifierForStyle can only be applied to extension declarations.")
        }

        guard
            let typeName = declaration.extendedType.as(IdentifierTypeSyntax.self)?.name,
            typeName.text == "View"
        else {
            throw CustomError.message("@ConvenienceModifierForStyle can only be applied to a `View` extension declaration.")
        }
        
        guard
            case .argumentList(let arguments) = node.arguments,
            arguments.count == 1,
            let styleNameArgument = arguments.first?.expression
        else {
            throw CustomError.message("@ConvenienceModifierForStyle macro expects one argument to be passed as `String`.")
        }

        let styleName = styleNameArgument.description.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
        let camelcasedStyleName = styleName.withFirstCharacterLowercased

        return [
            """
            public func \(raw: camelcasedStyleName)(_ style: some \(raw: styleName)) -> some View {
                    environment(\\.\(raw: camelcasedStyleName), Any\(raw: styleName)(style: style))
                }
            """
        ]
    }
}
