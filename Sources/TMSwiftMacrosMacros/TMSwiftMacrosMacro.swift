import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct TMSwiftMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UIComponentMacro.self,
        StyleMacro.self,
        RegisterStyleMacro.self,
        ConvenienceModifierForStyleMacro.self,
    ]
}
