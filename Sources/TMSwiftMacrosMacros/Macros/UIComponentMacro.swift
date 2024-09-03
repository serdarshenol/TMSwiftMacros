//
//  UIComponentMacro.swift
//  TMSwiftMacros
//
//  Created by Naoufal Medouri on 18/01/2024.
//  Copyright © 2024 Trackman. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum UIComponentMacro { }

// MARK: - MemberMacro
extension UIComponentMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            throw CustomError.message("@UIComponent can only be applied to struct declarations.")
        }

        let componentName = declaration.name.text
        let camelcasedComponentName = componentName.withFirstCharacterLowercased
        let access = declaration.modifiers.first(where: \.isNeededAccessLevelModifier)
        let configurationName = "\(componentName)StyleConfiguration"

        let genericParameterClause = declaration.genericParameterClause
        var contentNames = [String]()
        if let genericParameterList = genericParameterClause?.parameters {
            contentNames = genericParameterList.map { $0.name.text }
        }

        // Generate content declarations
        var contentDeclarations = [DeclSyntax]()
        var styleConfigParams = [String]()

        contentDeclarations.append(
            "typealias Configuration = \(raw: configurationName)"
        )

        for contentName in contentNames {
            let camelcasedName = contentName.withFirstCharacterLowercased
            contentDeclarations.append(
                "\(access)let \(raw: camelcasedName): () -> \(raw: contentName)")

            styleConfigParams.append(
                "\(camelcasedName): Configuration.\(contentName)(content: \(camelcasedName)())")
        }

        let styleDeclaration: DeclSyntax = "@Environment(\\.\(raw: camelcasedComponentName)Style) var style"
        let bodyDeclaration: DeclSyntax = "\(access)var body: some View {style.makeBody(configuration: Configuration(\(raw: styleConfigParams.joined(separator: ","))))}"

        let members: [DeclSyntax] =
        [styleDeclaration] +
        contentDeclarations +
        [bodyDeclaration]

        return members
    }
}
