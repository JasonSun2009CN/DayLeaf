//
//  RootView.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var selectedDate: Date = Date()
    @State private var selectedTag: Tag?
    @State private var editingEntry: DiaryEntry?
    @State private var sidebarCollapsed: Bool = false
    @State private var selectedSectionID: String? = "main"

    enum AppSection: String, CaseIterable, Identifiable {
        case main = "main"
        case trash = "trash"
        case settings = "settings"
        var id: String { rawValue }
    }

    private var selectedSection: AppSection? {
        AppSection(rawValue: selectedSectionID ?? "main")
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView(
                selectedDate: $selectedDate,
                selectedTag: $selectedTag,
                collapsed: $sidebarCollapsed
            )
            .navigationSplitViewColumnWidth(
                min: sidebarCollapsed ? 44 : 260,
                ideal: sidebarCollapsed ? 44 : 280,
                max: sidebarCollapsed ? 44 : 360
            )
        } content: {
            List(selection: $selectedSectionID) {
                ForEach(AppSection.allCases) { section in
                    NavigationLink(value: section.id) {
                        Label(section.rawValue.capitalized, systemImage: icon(for: section))
                    }
                    .tag(section.id)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedSection {
        case .main:
            EntryListView(
                selectedDate: $selectedDate,
                selectedTag: $selectedTag,
                editingEntry: $editingEntry
            )
        case .trash:
            TrashView()
        case .settings:
            SettingsView()
        case .none:
            EmptyView()
        }
    }

    private func icon(for section: AppSection) -> String {
        switch section {
        case .main:     return "book.closed"
        case .trash:    return "trash"
        case .settings:  return "gearshape"
        }
    }
}
