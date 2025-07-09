//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation
import UniformTypeIdentifiers

struct GalleryRoomTimelineItemContent: Hashable {
//    let filename: String
//    var caption: String?
//    var formattedCaption: AttributedString?
//    /// The original textual representation of the formatted caption directly from the event (usually HTML code)
//    var formattedCaptionHTMLString: String?
    
    let imageInfos: [ImageInfoProxy]
    let thumbnailInfos: [ImageInfoProxy]?
    
//    var blurhash: String?
//    var contentType: UTType?
}
