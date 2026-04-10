//
//  EntryListView.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

struct EntryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<DiaryEntry> { !$0.isDeleted }) private var allEntries: [DiaryEntry]

    @Binding var selectedDate: Date
    @Binding var selectedTag: Tag?
    @Binding var editingEntry: DiaryEntry?

    private var filteredEntries: [DiaryEntry] {
        let calendar = Calendar.current
        return allEntries.filter { entry in
            let dateMatch = calendar.isDate(entry.date, inSameDayAs: selectedDate)
            let tagMatch = selectedTag == nil || (entry.tags?.contains { $0.id == selectedTag?.id } ?? false)
            return dateMatch && tagMatch
        }.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        // If editing, show inline editor; otherwise show list
        if let entry = editingEntry {
            InlineEntryEditor(entry: entry, onDismiss: { editingEntry = nil })
        } else {
            listView
        }
    }

    @ViewBuilder
    private var listView: some View {
        VStack(spacing: 0) {
            // Date header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedDate, format: .dateTime.weekday(.wide))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(selectedDate, format: .dateTime.month().day().year())
                        .font(.title2.weight(.bold))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 20)

            // Entry list
            if filteredEntries.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            EntryCardView(
                                entry: entry,
                                onEdit: { editingEntry = entry },
                                onDelete: {
                                    entry.softDelete()
                                    try? modelContext.save()
                                }
                            )
                        }
                    }
                    .padding(20)
                }
            }

            // New entry button
            HStack {
                Spacer()
                Button {
                    let newEntry = DiaryEntry(date: selectedDate, mood: .neutral, content: "")
                    modelContext.insert(newEntry)
                    editingEntry = newEntry
                } label: {
                    Label("New Entry", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Spacer()
            }
            .padding(.vertical, 16)
        }
    }
}
