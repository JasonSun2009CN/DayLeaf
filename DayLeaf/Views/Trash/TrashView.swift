//
//  TrashView.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

struct TrashView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<DiaryEntry> { $0.isDeleted }, sort: \DiaryEntry.deletedAt, order: .reverse) private var trashedEntries: [DiaryEntry]

    var body: some View {
        NavigationStack {
            Group {
                if trashedEntries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "trash")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text("Trash is Empty")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(trashedEntries) { entry in
                            TrashItemRow(entry: entry)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(entry)
                                        try? modelContext.save()
                                    } label: {
                                        Label("Delete Forever", systemImage: "trash.slash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        entry.restore()
                                        try? modelContext.save()
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.green)
                                }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Trash")
            .toolbar {
                if !trashedEntries.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Empty Trash") {
                            for entry in trashedEntries {
                                modelContext.delete(entry)
                            }
                            try? modelContext.save()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

struct TrashItemRow: View {
    @Environment(\.modelContext) private var modelContext
    let entry: DiaryEntry

    var body: some View {
        HStack(spacing: 12) {
            Text(entry.mood.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, format: .dateTime.month().day().year())
                    .font(.subheadline.weight(.medium))
                if let title = entry.title, !title.isEmpty {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                if let deletedAt = entry.deletedAt {
                    Text("Deleted \(deletedAt, style: .relative) ago")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()

            // Recover button
            Button {
                entry.restore()
                try? modelContext.save()
            } label: {
                Label("Recover", systemImage: "arrow.uturn.backward")
                    .labelStyle(.iconOnly)
                    .font(.title3)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.green)
            .help("Recover this entry")
        }
        .padding(.vertical, 4)
    }
}
