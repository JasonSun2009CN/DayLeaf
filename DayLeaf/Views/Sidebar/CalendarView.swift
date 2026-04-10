//
//  CalendarView.swift
//  DayLeaf
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    let moodEmojis: [Date: String]

    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    private var monthLabel: String {
        displayedMonth.formatted(.dateTime.year().month(.wide))
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }

        let startWeekday = calendar.component(.weekday, from: firstDay)
        let leadingSpaces = startWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header
            HStack {
                Button { shiftMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthLabel)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button { shiftMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(.secondary)

            // Weekday labels
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(["Su","Mo","Tu","We","Th","Fr","Sa"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day cells — whole cell is one large tap target
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date {
                        DayCellView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            moodEmoji: moodEmojis[calendar.startOfDay(for: date)]
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 38)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func shiftMonth(by value: Int) {
        if let new = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = new
        }
    }
}

struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let moodEmoji: String?
    let action: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(foreground)

                if let emoji = moodEmoji {
                    Text(emoji)
                        .font(.caption2)
                } else {
                    Spacer(minLength: 12)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: .infinity)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .frame(minHeight: 44)
    }

    private var foreground: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return .primary
    }

    private var background: Color {
        if isSelected { return .accentColor }
        if isToday { return .accentColor.opacity(0.15) }
        return .clear
    }

    private var borderColor: Color {
        if isSelected { return .accentColor }
        return .gray.opacity(0.25)
    }
}
