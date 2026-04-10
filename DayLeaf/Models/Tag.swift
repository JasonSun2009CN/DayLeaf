//
//  Tag.swift
//  DayLeaf
//

import Foundation
import SwiftData

@Model
final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(inverse: \DiaryEntry.tags)
    var entries: [DiaryEntry]?

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.entries = []
    }
}
