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
    case gray_FAFAFA = 0xFAFAFA
    case gray_AFAEAE = 0xAFAEAE
    case gray_F6F6F6 = 0xF6F6F6
    case gray_A3A3A3 = 0xA3A3A3
    case gray_525252 = 0x525252
    case gray_DFE2EB = 0xDFE2EB
    case gray_F2F2F3 = 0xF2F2F3
    case gray_8C8C8C = 0x8C8C8C
    case gray_E6E6E6 = 0xE6E6E6
    case gray_AAAAAA = 0xAAAAAA

    case blue_005CA7 = 0x005CA7
    
    case black = 0x000000
    case black_181718 = 0x181718
    
    case red_B91C1C = 0xB91C1C

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
