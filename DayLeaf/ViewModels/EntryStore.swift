//
//  EntryStore.swift
//  DayLeaf
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class EntryStore {
    var selectedDate: Date = Date()
    var selectedTag: Tag?
    var selectedEntry: DiaryEntry?
    var showingEditor: Bool = false
    var editingEntry: DiaryEntry?

    /// Creates a new entry for the current selected date and opens the editor
    func createEntry(in context: ModelContext) {
        let entry = DiaryEntry(date: selectedDate, mood: .neutral, content: "")
        context.insert(entry)
        editingEntry = entry
        showingEditor = true
    }

    /// Opens an existing entry in the editor
    func editEntry(_ entry: DiaryEntry) {
        editingEntry = entry
        showingEditor = true
    }

    /// Saves and closes the editor
    func saveAndClose(in context: ModelContext) {
        editingEntry?.updatedAt = Date()
        try? context.save()
        showingEditor = false
        editingEntry = nil
    }

    /// Soft-deletes an entry (moves to trash)
    func trashEntry(_ entry: DiaryEntry, in context: ModelContext) {
        entry.softDelete()
        try? context.save()
        if selectedEntry?.id == entry.id {
            selectedEntry = nil
        }
    }

    /// Permanently deletes an entry
    func permanentlyDelete(_ entry: DiaryEntry, in context: ModelContext) {
        context.delete(entry)
        try? context.save()
    }

    /// Restores an entry from trash
    func restoreEntry(_ entry: DiaryEntry, in context: ModelContext) {
        entry.restore()
        try? context.save()
    }

    /// Returns the mood emoji for a given date based on the last entry's mood
    func moodEmoji(for date: Date, entries: [DiaryEntry]) -> String? {
        let calendar = Calendar.current
        let dayEntries = entries.filter {
            calendar.isDate($0.date, inSameDayAs: date) && !$0.isDeleted
        }
        return dayEntries.last?.mood.emoji
    }
}
