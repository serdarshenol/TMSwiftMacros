import TMSwiftMacros
import SwiftUI

// MARK: - Style
@Style(subViews: ["Title", "Icon"])
public protocol MyStyle {
}

//@RegisterStyle("MyStyle")
extension String {

}

//@ConvenienceHandleForStyle("MyStyle")
extension String {

}

//@Style(contentNames: ["Title", "LeadingIcon", "TrailingIcon"])
public protocol LabelStyle {

}

@Style(subViews: ["Title", "Icon"])
public protocol MyComponentStyle {}

@RegisterStyle("MyComponentStyle")
extension EnvironmentValues {

}

@UIComponent
public struct MyComponent<Title: View, Icon: View>: View {
}

@ConvenienceModifierForStyle("MyComponentStyle")
extension View {

}
