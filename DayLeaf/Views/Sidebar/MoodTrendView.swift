//
//  MoodTrendView.swift
//  DayLeaf
//

import SwiftUI

struct MoodTrendView: View {
    let entries: [DiaryEntry]

    private var last7Days: [(date: Date, mood: MoodType?)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayEntries = entries.filter {
                calendar.isDate($0.date, inSameDayAs: date) && !$0.isDeleted
            }
            let mood = dayEntries.last?.mood
            return (date, mood)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent 7 Days")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(last7Days, id: \.date) { item in
                    VStack(spacing: 4) {
                        Text(item.mood?.emoji ?? "·")
                            .font(.title3)
                        Text(item.date, format: .dateTime.weekday(.narrow))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
