//
//  ImageViewerPage.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 8/16/21.
//

import SwiftUI

struct ImageViewerPage: View {

    class ViewModel: ObservableObject {
        @Published var showingShareSheet = false
        @Published var showingCropAndRotateSheet = false

        let record: Record

        init(record: Record) {
            self.record = record
        }

        func tappedShareButton() {
            self.showingShareSheet = true
        }

        func tappedCropAndRotate() {
            self.showingCropAndRotateSheet = true
        }

        func finishedEditingImage(image: UIImage?) {
            guard let image = image else {
                return
            }
            let filePath = FileManager.documentsDirectory.appendingPathComponent(record.fileName)
            try! image.jpeg(.high)!.write(to: filePath)
            AppDelegate.ditto.store["records"].findByID(record._id).update { mutableDoc in
                mutableDoc?["updatedOn"].set(ISO8601DateFormatter().string(from: Date()))
            }
            self.showingCropAndRotateSheet = false
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel

    init(record: Record) {
        viewModel = ViewModel(record: record)
    }

    var body: some View {
        NavigationView {
            VStack {
                ZoomableScrollView {
                    Image(fileName: viewModel.record.fileName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.tappedShareButton()
                    }, label: {
                        Image(systemName:"square.and.arrow.up")
                        Text("Share")
                    }).sheet(isPresented: $viewModel.showingShareSheet, content: {
                        let fileName = viewModel.record.fileName
                        ShareSheet(activityItems: [UIImage(fileName: fileName)])
                    })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Close", action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        viewModel.showingCropAndRotateSheet = true
                    } label: {
                        Label("Crop and Rotate", systemImage: "crop.rotate")
                    }
                    .sheet(isPresented: $viewModel.showingCropAndRotateSheet, content: {
                        if let fileName = viewModel.record.fileName, let image = UIImage(fileName: fileName) {
                            ImageEditorView(image: image, finishedEditingCallback: { image in
                                viewModel.finishedEditingImage(image: image)
                            })
                        }
                    })
                }
            }
        }
    }
}
