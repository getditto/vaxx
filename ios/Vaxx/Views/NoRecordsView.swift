//
//  NoRecordsView.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 8/19/21.
//

import SwiftUI

struct NoRecordsView: View {

    var cameraButtonClicked: (() -> Void)? = nil
    var photoLibraryButtonClicked: (() -> Void)? = nil

    init(cameraButtonClicked: (() -> Void)? = nil, photoLibraryButtonClicked: (() -> Void)? = nil) {
        self.cameraButtonClicked = cameraButtonClicked
        self.photoLibraryButtonClicked = photoLibraryButtonClicked
    }

    var body: some View {
        VStack {
            Text("Add a picture of your vaccination card:")
                .padding()
            Button(action: {
                self.cameraButtonClicked?()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "camera")
                    Text("Take a Picture")
                }
            }
            .padding()
            Button(action: {
                self.photoLibraryButtonClicked?()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle")
                    Text("Import from Photo Library")
                }
            }
            .padding()
        }
    }
}

struct NoRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        NoRecordsView()
    }
}
