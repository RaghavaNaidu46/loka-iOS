import SwiftUI

/// A compact status indicator: colored dot + label on a tinted capsule.
struct StatusPill: View {
    let status: IssueStatus

    var body: some View {
        HStack(spacing: LokaSpacing.xs) {
            Circle()
                .fill(tint)
                .frame(width: 6, height: 6)
            Text(status.displayName.uppercased())
                .font(LokaFont.statusLabel)
                .foregroundStyle(tint)
        }
        .padding(.horizontal, LokaSpacing.sm)
        .padding(.vertical, LokaSpacing.xs)
        .background(Capsule().fill(tint.opacity(0.14)))
        .accessibilityLabel("Status: \(status.displayName)")
    }

    private var tint: Color { LokaColor.statusColor(status) }
}

// Retained alias for any legacy references.
typealias StatusBadge = StatusPill
