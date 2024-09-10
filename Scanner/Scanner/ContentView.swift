//
//  ContentView.swift
//  Scanner
//
//  Created by Natalia on 01.09.24.
//

import SwiftUI
import SwiftData
import UIKit
import PhotosUI
import SwiftUI
import Vision

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var images: [UIImage] = []
    @State private var isCamera = true

    var body: some View {
        VStack {
            if !images.isEmpty {
                ScrollView {
                    ForEach(images.indices, id: \.self) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                }
                
                Button("Save as PDF") {
                    saveImagesAsPDF(images: images)
                }
                .padding()
            } else {
                Text("No images selected")
                    .padding()
            }
            
            HStack {
                Button("Take Photo") {
                    isCamera = true
                    showImagePicker = true
                }
                .padding()
                
                Button("Select from Gallery") {
                    isCamera = false
                    showImagePicker = true
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            if isCamera {
                ImagePicker(isCamera: $isCamera) { selectedImages in
                    processImages(selectedImages)
                }
            } else {
                PhotoPicker(selectedImages: $images)
            }
        }
    }

    func processImages(_ selectedImages: [UIImage]) {
        var processedImages: [UIImage] = []
        let group = DispatchGroup()
        
        for image in selectedImages {
            group.enter()
            detectRectangle(from: image) { correctedImage in
                if let correctedImage = correctedImage {
                    processedImages.append(correctedImage)
                } else {
                    processedImages.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            images = processedImages
        }
    }

    func saveImagesAsPDF(images: [UIImage]) {
        let pdfMetaData = [
            kCGPDFContextTitle: "Images PDF",
            kCGPDFContextCreator: "SwiftUI"
        ]
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, pdfMetaData as? [String: Any])
        
        for image in images {
            UIGraphicsBeginPDFPage()
            if let cgImage = image.cgImage {
                let context = UIGraphicsGetCurrentContext()
                let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                context?.draw(cgImage, in: rect)
            }
        }
        
        UIGraphicsEndPDFContext()
        
        savePDFToDocuments(pdfData: pdfData as Data)
    }

    func savePDFToDocuments(pdfData: Data) {
        let filename = getDocumentsDirectory().appendingPathComponent("images.pdf")
        do {
            try pdfData.write(to: filename)
            print("PDF saved to: \(filename)")
        } catch {
            print("Could not save PDF: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
