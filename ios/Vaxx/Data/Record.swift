//
//  Record.swift
//  Vaxx
//
//  Created by Maximilian Alexander on 8/7/21.
//

import Foundation
import DittoSwift

struct Record: Codable {
    var _id: String
    var title: String
    var details: String
    var fileName: String
    var createdOn: Date
    var updatedOn: Date
    var ordinal: Float

    static var dateFormatter = ISO8601DateFormatter()

    static func fromDocument(_ document: DittoDocument) -> Self{
        return Record(
            _id: document["_id"].stringValue,
            title: document["title"].stringValue,
            details: document["details"].stringValue,
            fileName: document["fileName"].stringValue,
            createdOn: dateFormatter.date(from: document["createdOn"].stringValue)!,
            updatedOn: dateFormatter.date(from: document["updatedOn"].stringValue)!,
            ordinal: document["ordinal"].floatValue)
    }
}


extension Record: Identifiable {
    var id: String {
        return self._id
    }
}

extension Record: Hashable {
    
}
