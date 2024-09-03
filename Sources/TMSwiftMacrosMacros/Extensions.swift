//
//  Extensions.swift
//  TMSwiftMacros
//
//  Created by Naoufal Medouri on 24/01/2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - StringProtocol
extension StringProtocol {
    // Ref: https://github.com/apple/swift-syntax/blob/main/CodeGeneration/Sources/SyntaxSupport/String%2BExtensions.swift
    var withFirstCharacterLowercased: String { prefix(1).lowercased() + dropFirst() }
    var withFirstCharacterUppercased: String { prefix(1).uppercased() + dropFirst() }
}

// MARK: - DeclModifierSyntax
extension DeclModifierSyntax {
    // Ref: https://github.com/apple/swift-syntax/blob/main/Examples/Sources/MacroExamples/Implementation/Member/NewTypeMacro.swift
    var isNeededAccessLevelModifier: Bool {
        switch self.name.tokenKind {
        case .keyword(.public): return true
        default: return false
        }
    }
}

// MARK: - SyntaxStringInterpolation
extension SyntaxStringInterpolation {
    // Ref: https://github.com/apple/swift-syntax/blob/main/Examples/Sources/MacroExamples/Implementation/Member/NewTypeMacro.swift
    mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
        if let node {
            appendInterpolation(node)
        }
    }
}

