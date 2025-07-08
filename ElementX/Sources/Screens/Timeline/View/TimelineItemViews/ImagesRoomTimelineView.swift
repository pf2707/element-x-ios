//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

// <<thaith>> - REMOVE COMMENT THIS
struct ImagesRoomTimelineView: View {
    @Environment(\.timelineContext) private var context
    let timelineItem: ImagesRoomTimelineItem
    
    var hasMediaCaption: Bool { false /*timelineItem.content.caption != nil*/ }

    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                if timelineItem.content.imageInfos.count >= 4 {
                    GridRow {
                        loadableImage(content: timelineItem.content.imageInfos[0])
                            .cornerRadius(20, corners: .topLeft)
                            .cornerRadius(8, corners: .bottomRight)
                        loadableImage(content: timelineItem.content.imageInfos[1])
                            .cornerRadius(timelineItem.isOutgoing ? 2 : 20, corners: .topRight)
                            .cornerRadius(8, corners: .bottomLeft)
                    }
                    GridRow {
                        loadableImage(content: timelineItem.content.imageInfos[2])
                            .cornerRadius(20, corners: .bottomLeft)
                            .cornerRadius(8, corners: .topRight)
                        loadableImage(content: timelineItem.content.imageInfos[3], remaining: timelineItem.content.imageInfos.count - 4)
                            .cornerRadius(8, corners: .topLeft)
                            .cornerRadius(20, corners: .bottomRight)
                    }
                } else if timelineItem.content.imageInfos.count == 3 {
                    GridRow {
                        loadableImage(content: timelineItem.content.imageInfos[0])
                            .cornerRadius(20, corners: .topLeft)
                            .cornerRadius(8, corners: .bottomRight)
                        loadableImage(content: timelineItem.content.imageInfos[1])
                            .cornerRadius(2, corners: .topRight)
                            .cornerRadius(8, corners: .bottomLeft)
                    }
                    GridRow {
                        loadableImage(content: timelineItem.content.imageInfos[2])
                            .cornerRadius(20, corners: .bottomLeft)
                            .cornerRadius(8, corners: .topRight)
                        Color.clear
                    }
                } else if timelineItem.content.imageInfos.count == 2 {
                    GridRow {
                        loadableImage(content: timelineItem.content.imageInfos[0])
                            .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                        loadableImage(content: timelineItem.content.imageInfos[1])
                            .cornerRadius(2, corners: .topRight)
                            .cornerRadius(20, corners: .bottomRight)
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    private func loadableImage(content: ImageInfoProxy, remaining: Int = 0) -> some View {
        ZStack {
            LoadableImage(mediaSource: content.source,
                          mediaType: .timelineItem(uniqueID: timelineItem.id.uniqueID),
                          blurhash: nil,// content.blurhash,
                          size: content.size,
                          mediaProvider: context?.mediaProvider) {
                placeholder
            }
    //        .timelineMediaFrame(imageInfo: content)
              .aspectRatio(contentMode: .fill)
              
            if remaining > 0 {
                Color.theme(.black).opacity(0.65)
                    .overlay {
                        Text("+ \(remaining)")
                            .foregroundColor(.white)
                            .font(.Roboto(.medium, size: 20))
                    }
            }
        }
        .frame(width: 120, height: 120)
        .onTapGesture {
            context?.send(viewAction: .mediaTapped(itemID: timelineItem.id))
        }
        
//        if timelineItem.content.contentType == .gif {
//            LoadableImage(mediaSource: timelineItem.content.imageInfo.source,
//                          mediaType: .timelineItem(uniqueID: timelineItem.id.uniqueID),
//                          blurhash: timelineItem.content.blurhash,
//                          size: timelineItem.content.imageInfo.size,
//                          mediaProvider: context?.mediaProvider) {
//                placeholder
//            }
//            .timelineMediaFrame(imageInfo: timelineItem.content.imageInfo)
//        } else {
//            LoadableImage(mediaSource: timelineItem.content.thumbnailInfo?.source ?? timelineItem.content.imageInfo.source,
//                          mediaType: .timelineItem(uniqueID: timelineItem.id.uniqueID),
//                          blurhash: timelineItem.content.blurhash,
//                          size: timelineItem.content.thumbnailInfo?.size ?? timelineItem.content.imageInfo.size,
//                          mediaProvider: context?.mediaProvider) {
//                placeholder
//            }
//            .timelineMediaFrame(imageInfo: timelineItem.content.thumbnailInfo ?? timelineItem.content.imageInfo)
//        }
    }
    
    private var placeholder: some View {
        Rectangle()
            .foregroundColor(timelineItem.isOutgoing ? .compound._bgBubbleOutgoing : .compound._bgBubbleIncoming)
            .opacity(0.3)
    }
}
//
//#Preview {
//    ImagesRoomTimelineView()
//}
