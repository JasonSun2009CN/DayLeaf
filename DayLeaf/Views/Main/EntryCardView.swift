//
//  EntryCardView.swift
//  DayLeaf
//

import SwiftUI

struct EntryCardView: View {
    let entry: DiaryEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(alignment: .top, spacing: 12) {
                // Mood badge
                Text(entry.mood.emoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(entry.mood.label)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(entry.updatedAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    if let title = entry.title, !title.isEmpty {
                        Text(title)
                            .font(.headline)
                            .lineLimit(1)
                    }

                    Text(entry.content)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    if let tags = entry.tags, !tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(tags) { tag in
                                Text("#\(tag.name)")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Edit") { onEdit() }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        }
    }
}
