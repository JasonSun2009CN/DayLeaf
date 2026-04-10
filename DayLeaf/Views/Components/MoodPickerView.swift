//
//  MoodPickerView.swift
//  DayLeaf
//

import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: MoodType

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MoodType.allCases) { mood in
                Button {
                    selectedMood = mood
                } label: {
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.title2)
                        Text(mood.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 6)
                    .background {
                        if selectedMood == mood {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor.opacity(0.4), lineWidth: 1.5)
                                )
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    MoodPickerView(selectedMood: .constant(.happy))
        .padding()
}
