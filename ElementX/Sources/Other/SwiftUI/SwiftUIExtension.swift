//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation
import SwiftUI

enum FontRoboto: String {
    case black = "Roboto-Black"
    case extraBold = "Roboto-ExtraBold"
    case bold = "Roboto-Bold"
    case semibold = "Roboto-SemiBold"
    case semiboldItalic = "Roboto-SemiBoldItalic"
    case medium = "Roboto-Medium"
    case regular = "Roboto-Regular"
    case light = "Roboto-Light"
    case lightItalic = "Roboto-LightItalic"
    case thin = "Roboto-Thin"
    case italic = "Roboto-Italic"
}

enum ColorTheme: UInt {
    
    case gray_737373 = 0x737373
    
    case blue_005CA7 = 0x005CA7
    
    case black = 0x000000
    
    case white = 0xFFFFFF
}

extension Font {
    
    static func Roboto(_ name: FontRoboto, size: CGFloat) -> Font {
        .custom(name.rawValue, size: size)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    static func theme(_ name: ColorTheme, alpha: Double = 1) -> Color {
        Color(hex: name.rawValue, alpha: alpha)
    }
}
