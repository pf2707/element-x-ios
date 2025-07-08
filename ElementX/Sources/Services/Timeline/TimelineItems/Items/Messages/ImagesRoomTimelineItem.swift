//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation
import UniformTypeIdentifiers

struct ImagesRoomTimelineItem: EventBasedMessageTimelineItemProtocol, Equatable {
    let id: TimelineItemIdentifier
    let timestamp: Date
    let isOutgoing: Bool
    let isEditable: Bool
    let canBeRepliedTo: Bool
    var shouldBoost = false
    
    let sender: TimelineItemSender
    
    let content: ImagesRoomTimelineItemContent
    
    var properties = RoomTimelineItemProperties()
    
    var body: String {
        "" //content.caption ?? content.filename
    }
    
    var contentType: EventBasedMessageTimelineItemContentType {
        .images(content)
    }
}
