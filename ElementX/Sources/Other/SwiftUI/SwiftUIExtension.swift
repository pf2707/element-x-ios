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

extension Font {
    
    static func Roboto(_ name: FontRoboto, size: CGFloat) -> Font {
        .custom(name.rawValue, size: size)
    }
}
