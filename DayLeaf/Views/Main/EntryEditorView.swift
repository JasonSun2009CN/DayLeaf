//
//  EntryEditorView.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

struct EntryEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @Bindable var entry: DiaryEntry

    @State private var selectedMood: MoodType = .neutral
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var entryTags: [Tag] = []
    @State private var newTagName: String = ""
    @State private var showingTagInput: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    dateSection
                    Divider()
                    moodSection
                    Divider()
                    titleSection
                    Divider()
                    tagsSection
                    Divider()
                    contentSection
                }
                .padding(24)
            }
            .background(Color(nsColor: .windowBackgroundColor))
            .navigationTitle(entry.title == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedMood = entry.mood
                title = entry.title ?? ""
                content = entry.content
                entryTags = entry.tags ?? []
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Date")
            Text(entry.date, format: .dateTime.month().day().year().weekday())
                .font(.body.weight(.medium))
        }
    }

    @ViewBuilder
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Mood")
            MoodPickerView(selectedMood: $selectedMood)
        }
    }

    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Title (optional)")
            TextField("Give your entry a title...", text: $title)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Tags")
            FlowLayout(spacing: 6) {
                ForEach(entryTags) { tag in
                    TagChip(name: tag.name, isSelected: true) {
                        entryTags.removeAll { $0.id == tag.id }
                    }
                }
                addTagButton
            }
            if showingTagInput {
                newTagInputRow
            }
        }
    }

    @ViewBuilder
    private var addTagButton: some View {
        Button {
            showingTagInput.toggle()
        } label: {
            Label("Add Tag", systemImage: "plus")
                .font(.caption)
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var newTagInputRow: some View {
        HStack {
            TextField("New tag name", text: $newTagName)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onSubmit { addNewTag() }

            Button("Add") { addNewTag() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Content")
            TextEditor(text: $content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(minHeight: 200)
        }
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    // MARK: - Actions

    private func addNewTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        if let existing = allTags.first(where: { $0.name == name }) {
            if !entryTags.contains(where: { $0.id == existing.id }) {
                entryTags.append(existing)
            }
        } else {
            let newTag = Tag(name: name)
            modelContext.insert(newTag)
            entryTags.append(newTag)
        }
        newTagName = ""
        showingTagInput = false
    }

    private func save() {
        entry.mood = selectedMood
        entry.title = title.isEmpty ? nil : title
        entry.content = content
        entry.tags = entryTags
        entry.updatedAt = Date()
        try? modelContext.save()
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + result.positions[index].x,
                            y: bounds.minY + result.positions[index].y),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            self.size = CGSize(width: width, height: y + rowHeight)
        }
    }
}
