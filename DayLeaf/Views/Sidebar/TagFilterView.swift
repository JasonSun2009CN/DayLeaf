//
//  TagFilterView.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

struct TagFilterView: View {
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @Binding var selectedTag: Tag?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    TagChip(name: "All", isSelected: selectedTag == nil) {
                        selectedTag = nil
                    }

                    ForEach(allTags) { tag in
                        TagChip(name: tag.name, isSelected: selectedTag?.id == tag.id) {
                            selectedTag = tag
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct TagChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }
}
