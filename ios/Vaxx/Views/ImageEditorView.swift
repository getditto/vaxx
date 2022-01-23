//
//  TOViewController.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 1/22/22.
//

import SwiftUI
import TOCropViewController


struct ImageEditorView: UIViewControllerRepresentable {

    typealias DidCropCallback = ((UIImage?) -> Void)

    class Coordinator: NSObject, TOCropViewControllerDelegate {

        var finishedEditingCallback: DidCropCallback? = nil

        init(finishedEditingCallback: DidCropCallback?) {
            self.finishedEditingCallback = finishedEditingCallback
            super.init()
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            finishedEditingCallback?(image)
        }

        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            finishedEditingCallback?(nil)
        }

    }

    let image: UIImage
    let finishedEditingCallback: DidCropCallback?

    func makeUIViewController(context: Context) -> TOCropViewController {
        let controller = TOCropViewController(image: image)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {
        uiViewController.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(finishedEditingCallback: self.finishedEditingCallback)
    }

    typealias UIViewControllerType = TOCropViewController
}


struct ImageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditorView(image: UIImage(named: "sample_vaccine_card_cdc")!, finishedEditingCallback: { image in 

        })
    }
}
