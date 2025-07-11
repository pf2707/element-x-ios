//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

struct GalleryRoomTimelineView: View {
    @Environment(\.timelineContext) private var context
    let timelineItem: GalleryRoomTimelineItem
    
    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            VStack(alignment: .trailing, spacing: 4) {
                Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                    if timelineItem.content.galleryProxies.count >= 4 {
                        GridRow {
                            loadableGallery(at: 0)
                                .cornerRadius(20, corners: .topLeft)
                                .cornerRadius(8, corners: .bottomRight)
                            loadableGallery(at: 1)
                                .cornerRadius(timelineItem.isOutgoing ? 2 : 20, corners: .topRight)
                                .cornerRadius(8, corners: .bottomLeft)
                        }
                        GridRow {
                            loadableGallery(at: 2)
                                .cornerRadius(20, corners: .bottomLeft)
                                .cornerRadius(8, corners: .topRight)
                            loadableGallery(at: 3, remaining: timelineItem.content.galleryProxies.count - 4)
                                .cornerRadius(8, corners: .topLeft)
                                .cornerRadius(20, corners: .bottomRight)
                        }
                    } else if timelineItem.content.galleryProxies.count == 3 {
                        GridRow {
                            loadableGallery(at: 0)
                                .cornerRadius(20, corners: .topLeft)
                                .cornerRadius(8, corners: .bottomRight)
                            loadableGallery(at: 1)
                                .cornerRadius(2, corners: .topRight)
                                .cornerRadius(8, corners: .bottomLeft)
                        }
                        GridRow {
                            loadableGallery(at: 2)
                                .cornerRadius(20, corners: .bottomLeft)
                                .cornerRadius(8, corners: .topRight)
                            Color.clear
                                .frame(width: 120, height: 120)
                        }
                    } else if timelineItem.content.galleryProxies.count == 2 {
                        GridRow {
                            loadableGallery(at: 0)
                                .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                            loadableGallery(at: 1)
                                .cornerRadius(2, corners: .topRight)
                                .cornerRadius(20, corners: .bottomRight)
                        }
                    }
                }
                
                if timelineItem.hasMediaCaption {
                    if let attributedCaption = timelineItem.content.formattedCaption {
                        FormattedBodyText(attributedString: attributedCaption,
                                          additionalWhitespacesCount: timelineItem.additionalWhitespaces(),
                                          isOutgoing: timelineItem.isOutgoing,
                                          boostFontSize: timelineItem.shouldBoost)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                        .background(timelineItem.bubbleBackgroundColor)
                        .cornerRadius(10, corners: timelineItem.isOutgoing ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight])
                    } else if let caption = timelineItem.content.caption {
                        FormattedBodyText(text: caption,
                                          additionalWhitespacesCount: timelineItem.additionalWhitespaces(),
                                          isOutgoing: timelineItem.isOutgoing,
                                          boostFontSize: timelineItem.shouldBoost)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                        .background(timelineItem.bubbleBackgroundColor)
                        .frame(alignment: .trailing)
                        .cornerRadius(10, corners: timelineItem.isOutgoing ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight])
                    }
                }
            }
        }
    }
    
    private func gallery(at index: Int) -> GalleryInfoProxy {
        timelineItem.content.galleryProxies[index]
    }
    
    private func thumbnail(at index: Int) -> ImageInfoProxy? {
        timelineItem.content.thumbnailInfos?[index]
    }
    
    @ViewBuilder
    private func loadableGallery(at index: Int, remaining: Int = 0) -> some View {
        let gallery = gallery(at: index)
        ZStack {
            switch gallery {
            case .imageProxy(let proxy):
                loadable(image: proxy, thumbnail: thumbnail(at: index))
            case .videoProxy(let proxy):
                loadable(video: proxy, thumbnail: thumbnail(at: index))
            }
              
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
            context?.send(viewAction: .galleryTapped(itemID: timelineItem.id, childIndex: index))
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
    
    private func loadable(image content: ImageInfoProxy, thumbnail: ImageInfoProxy?) -> some View {
        LoadableImage(mediaSource: thumbnail?.source ?? content.source,
                      mediaType: .timelineItem(uniqueID: timelineItem.id.uniqueID),
                      blurhash: nil,// content.blurhash,
                      size: content.size,
                      mediaProvider: context?.mediaProvider) {
            placeholder
        }
          .aspectRatio(contentMode: .fill)
    }
    
    @ViewBuilder
    private func loadable(video content: VideoInfoProxy, thumbnail: ImageInfoProxy?) -> some View {
        if let thumbnailSource = thumbnail?.source {
            LoadableImage(mediaSource: thumbnailSource,
                          mediaType: .timelineItem(uniqueID: timelineItem.id.uniqueID),
                          blurhash: nil, //timelineItem.content.blurhash,
                          size: thumbnail?.size,
                          mediaProvider: context?.mediaProvider) { imageView in
                imageView
                    .overlay { playIcon }
            } placeholder: {
                placeholder
            }
        } else {
            playIcon
        }
    }
    
    private var placeholder: some View {
        Rectangle()
            .foregroundColor(timelineItem.isOutgoing ? .compound._bgBubbleOutgoing : .compound._bgBubbleIncoming)
            .opacity(0.3)
    }
    
    var playIcon: some View {
        Image(systemName: "play.circle.fill")
            .resizable()
            .frame(width: 40, height: 40)
            .background(.ultraThinMaterial, in: Circle())
            .foregroundColor(.white)
    }
}
