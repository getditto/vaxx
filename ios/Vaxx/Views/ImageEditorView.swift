//
//  TOViewController.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 1/22/22.
//

import SwiftUI
import CropViewController


struct ImageEditorView: UIViewControllerRepresentable {

    typealias DidCropCallback = ((UIImage?) -> Void)

    class Coordinator: NSObject, CropViewControllerDelegate {

        var finishedEditingCallback: DidCropCallback? = nil

        init(finishedEditingCallback: DidCropCallback?) {
            self.finishedEditingCallback = finishedEditingCallback
            super.init()
        }

        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            finishedEditingCallback?(nil)
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            finishedEditingCallback?(image)
        }
    }

    let image: UIImage
    let finishedEditingCallback: DidCropCallback?

    func makeUIViewController(context: Context) -> CropViewController {
        let controller = CropViewController(image: image)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {
        uiViewController.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(finishedEditingCallback: self.finishedEditingCallback)
    }

    typealias UIViewControllerType = CropViewController
}


struct ImageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditorView(image: UIImage(named: "sample_vaccine_card_cdc")!, finishedEditingCallback: { image in 

        })
    }
}
