//
//  SidebarView.swift
//  DayLeaf
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Query(filter: #Predicate<DiaryEntry> { !$0.isDeleted }) private var allEntries: [DiaryEntry]

    @Binding var selectedDate: Date
    @Binding var selectedTag: Tag?
    @Binding var collapsed: Bool

    private var moodEmojis: [Date: String] {
        let calendar = Calendar.current
        var map: [Date: String] = [:]
        for entry in allEntries {
            let day = calendar.startOfDay(for: entry.date)
            map[day] = entry.mood.emoji
        }
        return map
    }

    var body: some View {
        Group {
            if collapsed {
                collapsedView
            } else {
                expandedView
            }
        }
        .animation(.easeInOut(duration: 0.25), value: collapsed)
    }

    private var expandedView: some View {
        VStack(spacing: 0) {
            // Top: collapse toggle
            HStack {
                Spacer()
                Button {
                    collapsed.toggle()
                } label: {
                    Image(systemName: "sidebar.leading")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(8)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CalendarView(selectedDate: $selectedDate, moodEmojis: moodEmojis)
                    TagFilterView(selectedTag: $selectedTag)
                    MoodTrendView(entries: allEntries)
                }
                .padding(16)
            }
        }
        .frame(minWidth: 260, idealWidth: 280)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var collapsedView: some View {
        VStack(spacing: 0) {
            // Top: expand toggle
            Button {
                collapsed.toggle()
            } label: {
                Image(systemName: "sidebar.left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(8)

            Divider()
                .padding(.horizontal, 4)

            VStack(spacing: 16) {
                Image(systemName: "calendar")
                    .font(.title3)
                Image(systemName: "face.smiling")
                    .font(.title3)
                Image(systemName: "tag")
                    .font(.title3)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
            }
            .padding(.vertical, 16)

            Spacer()
        }
        .frame(width: 44)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
