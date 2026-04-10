//
//  InlineEntryEditor.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

/// Inline entry editor — like Apple Notes, edits directly in the main area.
struct InlineEntryEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @Bindable var entry: DiaryEntry
    let onDismiss: () -> Void

    @State private var selectedMood: MoodType
    @State private var title: String
    @State private var content: String
    @State private var entryTags: [Tag] = []
    @State private var newTagName: String = ""
    @State private var showingTagInput: Bool = false

    init(entry: DiaryEntry, onDismiss: @escaping () -> Void) {
        self.entry = entry
        self.onDismiss = onDismiss
        _selectedMood = State(initialValue: entry.mood)
        _title = State(initialValue: entry.title ?? "")
        _content = State(initialValue: entry.content)
        _entryTags = State(initialValue: entry.tags ?? [])
    }

    private var availableTags: [Tag] {
        allTags.filter { tag in
            !entryTags.contains { $0.id == tag.id }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Button {
                    save()
                    onDismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Done")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer()

                Button(role: .destructive) {
                    entry.softDelete()
                    try? modelContext.save()
                    onDismiss()
                } label: {
                    Image(systemName: "trash")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Mood
                    VStack(alignment: .leading, spacing: 8) {
                        label("Mood")
                        MoodPickerView(selectedMood: $selectedMood)
                    }

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        label("Title")
                        TextField("Title (optional)", text: $title)
                            .textFieldStyle(.plain)
                            .font(.title3.weight(.semibold))
                            .padding(10)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        label("Tags")
                        FlowLayout(spacing: 6) {
                            ForEach(entryTags) { tag in
                                TagChip(name: tag.name, isSelected: true) {
                                    entryTags.removeAll { $0.id == tag.id }
                                }
                            }
                            addTagButton
                        }

                        // Tag picker - select from existing tags
                        if !availableTags.isEmpty {
                            Menu {
                                ForEach(availableTags) { tag in
                                    Button(tag.name) {
                                        if !entryTags.contains(where: { $0.id == tag.id }) {
                                            entryTags.append(tag)
                                        }
                                    }
                                }
                            } label: {
                                Label("Select from existing", systemImage: "tag")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .menuStyle(.button)
                            .buttonStyle(.plain)
                        }

                        if showingTagInput {
                            newTagInputRow
                        }
                    }

                    // Content — with visible border to guide user
                    VStack(alignment: .leading, spacing: 6) {
                        label("Content")
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $content)
                                .font(.body)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 300)
                                .padding(10)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )

                            if content.isEmpty {
                                Text("Write your thoughts...")
                                    .font(.body)
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private func label(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
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
            TextField("Tag name", text: $newTagName)
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
