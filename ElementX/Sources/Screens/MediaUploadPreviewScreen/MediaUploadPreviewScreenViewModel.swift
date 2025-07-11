//
// Copyright 2022-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import MatrixRustSDK
import SwiftUI

typealias MediaUploadPreviewScreenViewModelType = StateStoreViewModel<MediaUploadPreviewScreenViewState, MediaUploadPreviewScreenViewAction>

class MediaUploadPreviewScreenViewModel: MediaUploadPreviewScreenViewModelType, MediaUploadPreviewScreenViewModelProtocol {
    private let userIndicatorController: UserIndicatorControllerProtocol
    private let roomProxy: JoinedRoomProxyProtocol
    private let mediaUploadingPreprocessor: MediaUploadingPreprocessor
    private let urls: [URL]
    private let threadRootEventID: String?
    
    private var processingTask: Task<[Result<MediaInfo, MediaUploadingPreprocessorError>], Never>
    private var requestHandle: SendAttachmentJoinHandleProtocol?
    private var requestGalleryHandle: SendGalleryJoinHandleProtocol?

    private var actionsSubject: PassthroughSubject<MediaUploadPreviewScreenViewModelAction, Never> = .init()
    
    var actions: AnyPublisher<MediaUploadPreviewScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(userIndicatorController: UserIndicatorControllerProtocol,
         roomProxy: JoinedRoomProxyProtocol,
         mediaUploadingPreprocessor: MediaUploadingPreprocessor,
         title: String?,
         urls: [URL],
         threadRootEventID: String?,
         shouldShowCaptionWarning: Bool) {
        self.userIndicatorController = userIndicatorController
        self.roomProxy = roomProxy
        self.mediaUploadingPreprocessor = mediaUploadingPreprocessor
        self.urls = urls
        self.threadRootEventID = threadRootEventID
        
        // Start processing the media whilst the user is reviewing it/adding a caption.
        processingTask = Task { await mediaUploadingPreprocessor.processMedias(at: urls) }
        
        super.init(initialViewState: MediaUploadPreviewScreenViewState(urls: urls,
                                                                       title: title,
                                                                       shouldShowCaptionWarning: shouldShowCaptionWarning,
                                                                       isRoomEncrypted: roomProxy.infoPublisher.value.isEncrypted))
    }
    
    override func process(viewAction: MediaUploadPreviewScreenViewAction) {
        // Get the current caption before all the processing starts.
        let caption = state.bindings.caption.nonBlankString
        
        switch viewAction {
        case .send:
            startLoading()
            //<thaith>: ATTACHMENTS ARE SENT HERE
            Task {
                if await processingTask.value.count == 1 {
                    switch await processingTask.value.first {
                    case .success(let mediaInfo):
                        switch await sendAttachment(mediaInfo: mediaInfo,
                                                    caption: caption,
                                                    threadRootEventID: threadRootEventID) {
                        case .success:
                            actionsSubject.send(.dismiss)
                        case .failure(let error):
                            MXLog.error("Failed sending attachment with error: \(error)")
                            showError(label: L10n.screenMediaUploadPreviewErrorFailedSending)
                        }
                        
                        stopLoading()
                    case .failure(let error):
                        MXLog.error("Failed processing media to upload with error: \(error)")
                        showError(label: L10n.screenMediaUploadPreviewErrorFailedProcessing)
                        stopLoading()
                    case .none:
                        stopLoading()
                    }
                } else {
                    var mediaInfos: [MediaInfo] = []
                    for result in await processingTask.value {
                        switch result {
                        case .success(let mediaInfo):
                            mediaInfos.append(mediaInfo)
                        case .failure(let error):
                            MXLog.error("Failed processing media to upload with error: \(error)")
                        }
                    }
                    switch await sendAttachments(mediaInfos: mediaInfos, caption: caption, threadRootEventID: threadRootEventID) {
                    case .success:
                        actionsSubject.send(.dismiss)
                    case .failure(let error):
                        MXLog.error("Failed sending attachments with error: \(error)")
                        showError(label: L10n.screenMediaUploadPreviewErrorFailedSending)
                    }
                    
                    stopLoading()
                }
            }
            
        case .cancel:
            requestHandle?.cancel()
            requestGalleryHandle?.cancel()
            actionsSubject.send(.dismiss)
        }
    }
    
    func stopProcessing() {
        processingTask.cancel()
    }
    
    // MARK: - Private
    
    private func sendAttachment(mediaInfo: MediaInfo, caption: String?, threadRootEventID: String?) async -> Result<Void, TimelineProxyError> {
        let requestHandle: ((SendAttachmentJoinHandleProtocol) -> Void) = { [weak self] handle in
            self?.requestHandle = handle
        }
        
        switch mediaInfo {
        case let .image(imageURL, thumbnailURL, imageInfo):
            return await roomProxy.timeline.sendImage(url: imageURL,
                                                      thumbnailURL: thumbnailURL,
                                                      imageInfo: imageInfo,
                                                      caption: caption,
                                                      threadRootEventID: threadRootEventID,
                                                      requestHandle: requestHandle)
        case let .video(videoURL, thumbnailURL, videoInfo):
            return await roomProxy.timeline.sendVideo(url: videoURL,
                                                      thumbnailURL: thumbnailURL,
                                                      videoInfo: videoInfo,
                                                      caption: caption,
                                                      threadRootEventID: threadRootEventID,
                                                      requestHandle: requestHandle)
        case let .audio(audioURL, audioInfo):
            return await roomProxy.timeline.sendAudio(url: audioURL,
                                                      audioInfo: audioInfo,
                                                      caption: caption,
                                                      threadRootEventID: threadRootEventID,
                                                      requestHandle: requestHandle)
        case let .file(fileURL, fileInfo):
            return await roomProxy.timeline.sendFile(url: fileURL,
                                                     fileInfo: fileInfo,
                                                     caption: caption,
                                                     threadRootEventID: threadRootEventID,
                                                     requestHandle: requestHandle)
        }
    }
    
    private func sendAttachments(mediaInfos: [MediaInfo], caption: String?, threadRootEventID: String?) async -> Result<Void, TimelineProxyError> {
        let requestHandle: ((SendGalleryJoinHandleProtocol) -> Void) = { [weak self] handle in
            self?.requestGalleryHandle = handle
        }
        
        var inputInfo: [MediaInfo] = []
        for mediaInfo in mediaInfos {
            switch mediaInfo {
            case let .image(url, thumbURL, info):
                inputInfo.append(.image(imageURL: url, thumbnailURL: thumbURL, imageInfo: info))
            case let .video(url, thumbUrl, info):
                inputInfo.append(.video(videoURL: url, thumbnailURL: thumbUrl, videoInfo: info))
            default: break
            }
        }
        return await roomProxy.timeline.sendGallery(mediaInfos: inputInfo, caption: caption, threadRootEventID: threadRootEventID, requestHandle: requestHandle)
    }
    
    private static let loadingIndicatorIdentifier = "\(MediaUploadPreviewScreenViewModel.self)-Loading"
    
    private func startLoading() {
        userIndicatorController.submitIndicator(UserIndicator(id: Self.loadingIndicatorIdentifier,
                                                              type: .modal(progress: .indeterminate, interactiveDismissDisabled: false, allowsInteraction: true),
                                                              title: L10n.commonSending,
                                                              persistent: true))
        
        state.shouldDisableInteraction = true
    }
    
    private func stopLoading() {
        userIndicatorController.retractIndicatorWithId(Self.loadingIndicatorIdentifier)
        state.shouldDisableInteraction = false
        requestHandle = nil
        requestGalleryHandle = nil
    }
    
    private func showError(label: String) {
        userIndicatorController.submitIndicator(UserIndicator(title: label))
    }
}

extension NSAttributedString {
    var nonBlankString: String? {
        guard !string.isBlank else { return nil }
        return string
    }
}
