//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

struct ImagesMediaEventsTimelineView: View {
    @Environment(\.timelineContext) private var context
    let timelineItem: ImagesRoomTimelineItem
    
    var body: some View {
        Color.green // Let the image aspect fill in place
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.commonImage)
    }
}

//#Preview {
//    ImagesMediaEventsTimelineView()
//}
