//
//  DiaryEntry.swift
//  DayLeaf
//

import Foundation
import SwiftData

@Model
final class DiaryEntry {
    var id: UUID
    var date: Date
    var moodRaw: String
    var title: String?
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var deletedAt: Date?

    var tags: [Tag]?

    var mood: MoodType {
        get { MoodType(rawValue: moodRaw) ?? .neutral }
        set { moodRaw = newValue.rawValue }
    }

    init(
        date: Date = Date(),
        mood: MoodType = .neutral,
        title: String? = nil,
        content: String = "",
        tags: [Tag]? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.moodRaw = mood.rawValue
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.deletedAt = nil
        self.tags = tags ?? []
    }

    func softDelete() {
        isDeleted = true
        deletedAt = Date()
    }

    func restore() {
        isDeleted = false
        deletedAt = nil
    }
}
