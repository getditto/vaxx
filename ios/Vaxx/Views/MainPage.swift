//
//  ContentView.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 8/7/21.
//

import SwiftUI
import CombineDitto
import DittoSwift
import Combine

struct MainPage: View {
    
    class ViewModel: ObservableObject {
        var bag = Set<AnyCancellable>()
        
        @Published var records = [Record]()
        @Published var showingImagePicker = false
        @Published var showingCamera = false
        @Published var inputImage: UIImage?
        @Published var editMode: EditMode = EditMode.inactive
        @Published var isPresentingImageViewerPage = false
        @Published var tappedRecord: Record?
        @Published var recordToDelete: Record?
        @Published var showingCropAndRotateSheet = false
        @Published var showDeleteActionConfirmation = false
        @Published var recordToCropAndRotate: Record? = nil
        
        init() {
            AppDelegate.ditto.store["records"].findAll()
                .sort("ordinal", direction: .ascending)
                .publisher()
                .map({ $0.documents.map { Record.fromDocument($0) } })
                .assign(to: &$records)
        }
        
        func addImage(image: UIImage) {
            let fileName = "\(UUID().uuidString).jpg"
            let filePath = FileManager.documentsDirectory.appendingPathComponent(fileName)
            try! image.jpeg(.high)!.write(to: filePath)
            var ordinal: Float = 0
            if let lastOrdinal = self.records.last?.ordinal {
                ordinal = lastOrdinal + 1
            }
            try! AppDelegate.ditto.store["records"].insert([
                "title": "",
                "details": "",
                "fileName": fileName,
                "createdOn": ISO8601DateFormatter().string(from: Date()),
                "updatedOn": ISO8601DateFormatter().string(from: Date()),
                "ordinal": ordinal
            ])
        }
        
        func tappedDeleteButton(record: Record) {
            self.recordToDelete = record
            showDeleteActionConfirmation = true
        }

        func delete() {
            self.showDeleteActionConfirmation = false
            self.recordToDelete = nil
            guard let record = self.recordToDelete else { return }
            AppDelegate.ditto.store["records"].findByID(record._id).remove()
        }

        func cancelDelete() {
            self.showDeleteActionConfirmation = false
            self.recordToDelete = nil
        }

        func move(from source: IndexSet, to destination: Int) {
            records.move(fromOffsets: source, toOffset: destination)
            for (index,record) in records.enumerated() {
                AppDelegate.ditto.store["records"].findByID(record._id).update { mutableDoc in
                    mutableDoc?["ordinal"].set(index)
                }
            }
        }

        func tappedRecord(record: Record) {
            self.isPresentingImageViewerPage = true
            self.tappedRecord = record
        }

        func tappedCropAndRotate(record: Record) {
            self.showingCropAndRotateSheet = true
            self.recordToCropAndRotate = record
        }

        func finishedEditingImage(image: UIImage?) {
            guard let image = image, let record = recordToCropAndRotate else {
                return
            }
            let filePath = FileManager.documentsDirectory.appendingPathComponent(record.fileName)
            try! image.jpeg(.high)!.write(to: filePath)
            AppDelegate.ditto.store["records"].findByID(record._id).update { mutableDoc in
                mutableDoc?["updatedOn"].set(ISO8601DateFormatter().string(from: Date()))
            }
            self.showingCropAndRotateSheet = false
            self.recordToCropAndRotate = nil
        }

        func tappedReorderButton() {
            editMode = editMode == .inactive ? .active : .inactive
        }
    }

    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.records.count > 0 {
                    List {
                        ForEach(viewModel.records, id: \.id) { record in
                            Image(fileName: record.fileName)
                                .resizable()
                                .scaledToFit()
                                .onTapGesture {
                                    viewModel.tappedRecord(record: record)
                                }
                                .sheet(isPresented: $viewModel.isPresentingImageViewerPage) {
                                    if let tappedRecord = viewModel.tappedRecord {
                                        ImageViewerPage(record: tappedRecord)
                                    }
                                    else { EmptyView () }
                                }
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        viewModel.tappedCropAndRotate(record: record)
                                    } label: {
                                        Label("Crop & Rotate", systemImage: "crop.rotate")
                                    }
                                    .tint(.blue)

                                    Button(role: .destructive) {
                                        viewModel.tappedDeleteButton(record: record)
                                    } label: {
                                        Label("Delete Record", systemImage: "trash.fill")
                                    }
                                }
                        }
                        .onMove(perform: viewModel.move)


                    }.environment(\.editMode, $viewModel.editMode)
                } else {
                    NoRecordsView(cameraButtonClicked: {
                        viewModel.showingCamera = true
                    }, photoLibraryButtonClicked: {
                        viewModel.showingImagePicker = true
                    })
                }
            }
            .confirmationDialog("Are you sure?", isPresented: $viewModel.showDeleteActionConfirmation, titleVisibility: .visible) {
                Button("Yes, Delete", role: .destructive) {
                    viewModel.delete()
                }
                .accentColor(.red)
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
            }
            .sheet(isPresented: $viewModel.showingCamera, content: {
                ImagePicker(sourceType: .camera, selectedImage: { image in
                    self.viewModel.addImage(image: image)
                })
            })
            .sheet(isPresented: $viewModel.showingImagePicker, content: {
                ImagePicker(sourceType: .photoLibrary, selectedImage: { image in
                    self.viewModel.addImage(image: image)
                })
            })
            .sheet(isPresented: $viewModel.showingCropAndRotateSheet, content: {
                if let fileName = viewModel.recordToCropAndRotate?.fileName, let image = UIImage(fileName: fileName) {
                    ImageEditorView(image: image, finishedEditingCallback: { image in
                        viewModel.finishedEditingImage(image: image)
                    })
                } else {
                    EmptyView()
                }
            })
            .sheet(isPresented: $viewModel.showingCamera, content: {
                ImagePicker(sourceType: .camera, selectedImage: { image in
                    self.viewModel.addImage(image: image)
                })
            })
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Reorder") {
                        viewModel.tappedReorderButton()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            viewModel.showingCamera = true
                        }) {
                            Label("Take a picture", systemImage: "camera")
                        }
                        Button(action: {
                            viewModel.showingImagePicker = true
                        }) {
                            Label("Import from Photo Library", systemImage: "photo.on.rectangle")
                        }
                    }
                label: {
                    Label("Add", systemImage: "plus")
                }
                }
            }
            .navigationTitle("Vaxx")
        }
        
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
