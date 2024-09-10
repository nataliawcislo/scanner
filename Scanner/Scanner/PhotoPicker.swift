//
//  PhotoPicker.swift
//  Scanner
//
//  Created by Natalia on 01.09.24.
//

import Foundation
import SwiftUI
import PhotosUI


struct PhotoPicker: View {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        PhotoPickerView(selectedImages: $selectedImages) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var onDismiss: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // 0 means unlimited selection
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.selectedImages.removeAll()

            let group = DispatchGroup()

            for result in results {
                group.enter()

                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        self.parent.selectedImages.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                picker.dismiss(animated: true, completion: self.parent.onDismiss)
            }
        }
    }
}
