//
//  EmptyStateView.swift
//  DayLeaf
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary.opacity(0.5))

            Text("No Entries Yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("Tap the button below to record your first moment.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 240)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
