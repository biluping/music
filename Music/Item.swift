//
//  Item.swift
//  Music
//
//  Created by rabbit on 2024/10/5.
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
