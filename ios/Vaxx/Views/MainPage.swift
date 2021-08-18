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
        @Published var tappedRecordFileName: String?
        @Published var showingShareSheet = false
        
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
        
        func delete(at offsets: IndexSet) {
            let idsToDelete = offsets.map { self.records[$0]._id }
            AppDelegate.ditto.store.write { trx in
                for idToDelete in idsToDelete {
                    trx["records"].findByID(idToDelete).remove()
                }
            }
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
            self.tappedRecordFileName = record.fileName
        }
    }
    
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.records, id: \.id) { record in
                    Image(fileName: record.fileName)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            viewModel.tappedRecord(record: record)
                        }
                        .sheet(isPresented: $viewModel.isPresentingImageViewerPage) {
                            ImageViewerPage(isPresentingSheet: $viewModel.isPresentingImageViewerPage, recordFileName: $viewModel.tappedRecordFileName)
                        }
                }
                .onDelete(perform: viewModel.delete)
                .onMove(perform: viewModel.move)
            }
            .navigationTitle("Vaxx")
            .navigationBarItems(leading:
                                    HStack {
                                        Button(action: {
                                            self.viewModel.showingImagePicker = true
                                        }) {
                                            Image(systemName: "doc.fill.badge.plus").imageScale(.large)
                                        }.sheet(isPresented: $viewModel.showingImagePicker, content: {
                                            ImagePicker(sourceType: .photoLibrary, selectedImage: { image in
                                                self.viewModel.addImage(image: image)
                                            })
                                        })
                                        Spacer(minLength: 12)
                                        Button(action: {
                                            self.viewModel.showingCamera = true
                                        }) {
                                            Image(systemName: "camera.fill").imageScale(.large)
                                        }.sheet(isPresented: $viewModel.showingCamera, content: {
                                            ImagePicker(sourceType: .camera, selectedImage: { image in
                                                self.viewModel.addImage(image: image)
                                            })
                                        })
                                    },
                                trailing: EditButton()
            )
        }
        
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
