//
// Copyright 2023, 2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import PhotosUI
import SwiftUI

enum PhotoLibraryPickerAction {
//    case selectFile(URL)
    case selectFiles([URL])
    case cancel
    case error(PhotoLibraryPickerError)
}

enum PhotoLibraryPickerError: Error {
    case failedLoadingFileRepresentation(Error?)
    case failedCopyingFile
}

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    private let userIndicatorController: UserIndicatorControllerProtocol
    private let callback: (PhotoLibraryPickerAction) -> Void
    
    private let allowMultipleSelections: Bool
    
    init(userIndicatorController: UserIndicatorControllerProtocol,
         allowMultipleSelections: Bool,
         callback: @escaping (PhotoLibraryPickerAction) -> Void) {
        self.userIndicatorController = userIndicatorController
        self.callback = callback
        self.allowMultipleSelections = allowMultipleSelections
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = allowMultipleSelections ? 0 : 1
        
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = context.coordinator
        
        return pickerViewController
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private var photoLibraryPicker: PhotoLibraryPicker
        
        init(_ photoLibraryPicker: PhotoLibraryPicker) {
            self.photoLibraryPicker = photoLibraryPicker
        }
        
        // MARK: PHPickerViewControllerDelegate
        
        private static let loadingIndicatorIdentifier = "\(PhotoLibraryPicker.self)-Loading"
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider,
                  let contentType = provider.preferredContentType else {
                photoLibraryPicker.callback(.cancel)
                return
            }
                        
            photoLibraryPicker.userIndicatorController.submitIndicator(UserIndicator(id: Self.loadingIndicatorIdentifier, type: .modal, title: L10n.commonLoading))
            defer {
                photoLibraryPicker.userIndicatorController.retractIndicatorWithId(Self.loadingIndicatorIdentifier)
            }
            
            var files: [URL] = []
            self.processPicking(results: results, index: 0, files: files) {
                DispatchQueue.main.async {
                    picker.delegate = nil
//                    picker.dismiss(animated: true)
                }
            }
        }
        
        func processPicking(results: [PHPickerResult], index: Int, files: [URL], completion: @escaping () -> Void) {
            if index < results.count {
                let result = results[index]
                guard let contentType = result.itemProvider.preferredContentType else {
                    self.processPicking(results: results, index: index + 1, files: files, completion: completion)
                    return
                }
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: contentType.type.identifier) { url, error in
                    guard let url else {
                        MXLog.error("failedLoadingFileRepresentation")
                        return
                    }
                    
                    var newFiles = files
                    do {
                        let _ = url.startAccessingSecurityScopedResource()
                        let newURL = try FileManager.default.copyFileToTemporaryDirectory(file: url)
                        url.stopAccessingSecurityScopedResource()
                        
                        newFiles.append(newURL)
                    } catch {
                        MXLog.error("failedCopyingFile: \(error)")
                    }
                    
                    self.processPicking(results: results, index: index + 1, files: newFiles, completion: completion)
                }
            } else {
                if files.isEmpty {
                    Task { @MainActor in
                        self.photoLibraryPicker.callback(.error(.failedCopyingFile))
                    }
                    
                    return
                }
                
                Task { @MainActor in
                    self.photoLibraryPicker.callback(.selectFiles(files))
                }
                
                completion()
            }
        }
    }
}
