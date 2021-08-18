//
//  FileManagerExtensions.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 8/10/21.
//

import Foundation


extension FileManager {
    static var documentsDirectory:  URL  {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
