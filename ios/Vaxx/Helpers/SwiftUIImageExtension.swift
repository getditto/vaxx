//
//  SwiftUIImageExtension.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 8/10/21.
//

import SwiftUI

extension Image {
    init(fileName: String) {
        let path = FileManager.documentsDirectory.appendingPathComponent(fileName)
        let data = try! Data(contentsOf: path)
        let image = UIImage(data: data)!
        self.init(uiImage: image)
    }
}

extension UIImage {
    convenience init(fileName: String) {
        let path = FileManager.documentsDirectory.appendingPathComponent(fileName)
        let data = try! Data(contentsOf: path)
        self.init(data: data)!
    }
}
