//
//  SettingsView.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @AppStorage("selectedTheme") private var selectedTheme: String = "system"
    @AppStorage("enablePasscode") private var enablePasscode: Bool = false
    @AppStorage("useFaceID") private var useFaceID: Bool = false

    @State private var newTagName: String = ""
    @State private var showingAddTag: Bool = false
    @State private var isManagingTags: Bool = false
    @State private var renamingTag: Tag? = nil
    @State private var renameText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Privacy
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("🔒 Privacy")

                        VStack(spacing: 0) {
                            Toggle("Enable Passcode Lock", isOn: $enablePasscode)
                                .padding(.vertical, 8)

                            if enablePasscode {
                                Divider()
                                Toggle("Use Face ID / Touch ID", isOn: $useFaceID)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // MARK: - Tags
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("🏷️ Tags")

                        VStack(alignment: .leading, spacing: 12) {
                            if allTags.isEmpty {
                                Text("No tags yet")
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 8)
                            } else {
                                FlowLayout(spacing: 8) {
                                    ForEach(allTags) { tag in
                                        if renamingTag?.id == tag.id {
                                            // Rename mode
                                            HStack(spacing: 4) {
                                                TextField("Tag name", text: $renameText)
                                                    .textFieldStyle(.roundedBorder)
                                                    .frame(width: 100)
                                                Button {
                                                    saveRename()
                                                } label: {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundStyle(.green)
                                                }
                                                .buttonStyle(.plain)
                                                Button {
                                                    cancelRename()
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundStyle(.secondary)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } else if isManagingTags {
                                            // Manage mode - show delete and rename buttons
                                            ManagedTagChip(
                                                name: tag.name,
                                                onRename: {
                                                    startRenaming(tag)
                                                },
                                                onDelete: {
                                                    deleteTag(tag)
                                                }
                                            )
                                        } else {
                                            // Normal display mode
                                            Text(tag.name)
                                                .font(.caption.weight(.medium))
                                                .foregroundStyle(.primary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 5)
                                                .background(
                                                    Capsule()
                                                        .fill(Color.gray.opacity(0.15))
                                                )
                                        }
                                    }
                                }
                            }

                            // Action buttons row
                            if !showingAddTag && !isManagingTags {
                                HStack(spacing: 16) {
                                    Button {
                                        showingAddTag = true
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add Tag")
                                        }
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.accentColor)
                                    }
                                    .buttonStyle(.plain)

                                    if !allTags.isEmpty {
                                        Button {
                                            isManagingTags = true
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: "pencil.circle")
                                                Text("Manage")
                                            }
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.orange)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            } else if showingAddTag {
                                HStack(spacing: 8) {
                                    TextField("New tag name", text: $newTagName)
                                        .textFieldStyle(.roundedBorder)
                                    Button("Add") {
                                        addNewTag()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                                    Button("Cancel") {
                                        showingAddTag = false
                                        newTagName = ""
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            } else if isManagingTags {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Click tag name to rename, trash icon to delete")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Button {
                                        isManagingTags = false
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("Done")
                                        }
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.green)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // MARK: - Appearance
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("🎨 Appearance")

                        VStack(spacing: 0) {
                            HStack {
                                Text("Theme")
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(.vertical, 8)

                            Picker("", selection: $selectedTheme) {
                                Text("Light").tag("light")
                                Text("Dark").tag("dark")
                                Text("System").tag("system")
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal, 16)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // MARK: - Data
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("📦 Data")

                        VStack(spacing: 0) {
                            settingsButton("Export Data", icon: "square.and.arrow.up") {
                                // v2 feature placeholder
                            }

                            Divider()

                            settingsButton("Backup", icon: "archivebox") {
                                // v2 feature placeholder
                            }

                            Divider()

                            settingsButton("Clear Trash", icon: "trash", color: .red) {
                                // v2 feature placeholder
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // MARK: - Version
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("📱 About")

                        HStack {
                            Text("Version")
                            Text("v1.0.0")
                                .foregroundStyle(.secondary)
                                .padding(.leading, 8)
                            Spacer()
                        }
                        .padding(16)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .navigationTitle("Settings")
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }

    @ViewBuilder
    private func settingsButton(_ title: String, icon: String, color: Color = .primary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 20)
                Text(title)
                    .foregroundStyle(color)
                Spacer()
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private func deleteTag(_ tag: Tag) {
        modelContext.delete(tag)
        try? modelContext.save()
    }

    private func startRenaming(_ tag: Tag) {
        renamingTag = tag
        renameText = tag.name
    }

    private func saveRename() {
        guard let tag = renamingTag else { return }
        let newName = renameText.trimmingCharacters(in: .whitespaces)
        guard !newName.isEmpty else {
            cancelRename()
            return
        }
        // Check for duplicate
        if allTags.contains(where: { $0.name == newName && $0.id != tag.id }) {
            cancelRename()
            return
        }
        tag.name = newName
        try? modelContext.save()
        cancelRename()
    }

    private func cancelRename() {
        renamingTag = nil
        renameText = ""
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            let tag = allTags[index]
            modelContext.delete(tag)
        }
        try? modelContext.save()
    }

    private func addNewTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        guard !allTags.contains(where: { $0.name == name }) else {
            newTagName = ""
            showingAddTag = false
            return
        }

        let newTag = Tag(name: name)
        modelContext.insert(newTag)
        try? modelContext.save()

        newTagName = ""
        showingAddTag = false
    }
}

// MARK: - Managed Tag Chip

struct ManagedTagChip: View {
    let name: String
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Button {
                onRename()
            } label: {
                Text(name)
                    .font(.caption.weight(.medium))
            }
            .buttonStyle(.plain)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.caption2)
                    .foregroundStyle(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                .background(Capsule().fill(Color.orange.opacity(0.08)))
        )
    }
}
