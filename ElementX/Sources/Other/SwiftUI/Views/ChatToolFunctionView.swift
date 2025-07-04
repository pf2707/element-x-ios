//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

struct ChatToolFunctionView: View {
    @ObservedObject var context: ComposerToolbarViewModel.Context

    var body: some View {
        Grid(horizontalSpacing: 40, verticalSpacing: 16) {
            GridRow {
                item(caption: "Camera",
                     icon: "ic_tool_camera",
                     color: Color.theme(.blue_D4F3FC), viewAction: .attach(.camera))
                item(caption: "Gallery",
                     icon: "ic_tool_photo_library",
                     color: Color.theme(.purple_DAE4FE), viewAction: .attach(.photoLibrary))
                item(caption: "Document",
                     icon: "ic_tool_document",
                     color: Color.theme(.yellow_F0F2B8), viewAction: .attach(.file))
            }
            GridRow {
                item(caption: "Contact",
                     icon: "ic_tool_contact",
                     color: Color.theme(.orange_F8D9C8), viewAction: .contact)
                
                if context.viewState.isLocationSharingEnabled {
                    item(caption: "Location",
                         icon: "ic_tool_location",
                         color: Color.theme(.green_E1FAE8), viewAction: .attach(.location))
                        .accessibilityIdentifier(A11yIdentifiers.roomScreen.attachmentPickerLocation)
                }
                
                item(caption: "Audio",
                     icon: "ic_tool_audio",
                     color: Color.theme(.pink_F4DAEE), viewAction: .voiceMessage(.startRecording))
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func item(caption: String, icon: String, color: Color, viewAction: ComposerToolbarViewAction) -> some View {
        Button {
            context.send(viewAction: viewAction)
        } label: {
            VStack(alignment: .center, spacing: 3) {
                color
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                    .overlay {
                        Image(icon)
                    }
                Text(caption)
                    .font(.Roboto(.regular, size: 14))
                    .foregroundColor(.theme(.black_262626))
            }
        }

    }
}
