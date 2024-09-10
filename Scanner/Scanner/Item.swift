//
//  Item.swift
//  Scanner
//
//  Created by Natalia on 01.09.24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
