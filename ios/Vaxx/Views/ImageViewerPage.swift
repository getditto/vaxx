//
//  ImageViewerPage.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 8/16/21.
//

import SwiftUI

struct ImageViewerPage: View {

    @State var isShowingShareSheet: Bool = false
    @Binding var isPresentingSheet: Bool
    @Binding var recordFileName: String?

    var body: some View {
        NavigationView {
            ZoomableScrollView {
                if let fileName = recordFileName {
                    Image(fileName: fileName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }.navigationBarItems(
                leading: Button(action: {
                    isShowingShareSheet = true
                }, label: {
                    Image(systemName:"square.and.arrow.up")
                    Text("Share")
                }).sheet(isPresented: $isShowingShareSheet, content: {
                    if let fileName = recordFileName {
                        ShareSheet(activityItems: [UIImage(fileName: fileName)])
                    }
                }),
                trailing: Button("Close", action: { isPresentingSheet = false }))
        }
    }
}

struct ImageViewerPage_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewerPage(isPresentingSheet: .constant(true), recordFileName: .constant(nil))
    }
}
