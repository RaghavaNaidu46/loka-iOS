import SwiftUI

/// A poll: tap an option to vote, then the rows animate into result bars with
/// percentages. Voting is local (sample/preview) state.
struct PollView: View {
    let poll: PostPoll
    var interactive: Bool = true

    @State private var votes: [Int]
    @State private var selected: Int?

    init(poll: PostPoll, interactive: Bool = true) {
        self.poll = poll
        self.interactive = interactive
        _votes = State(initialValue: poll.options.map(\.votes))
        _selected = State(initialValue: poll.userVotedIndex)
    }

    private var total: Int { votes.reduce(0, +) }
    private var voted: Bool { selected != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            Label(poll.question, systemImage: "chart.bar.xaxis")
                .font(LokaFont.calloutEmphasized)
                .foregroundStyle(LokaColor.textPrimary)

            ForEach(Array(poll.options.enumerated()), id: \.element.id) { index, option in
                optionRow(index: index, text: option.text)
            }

            Text("\(total) vote\(total == 1 ? "" : "s")")
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.textTertiary)
        }
        .padding(LokaSpacing.md)
        .background(LokaColor.surfaceElevated, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                .strokeBorder(LokaColor.border, lineWidth: 0.5)
        )
    }

    private func optionRow(index: Int, text: String) -> some View {
        let fraction = total > 0 ? Double(votes[index]) / Double(total) : 0
        let isChoice = selected == index

        return Button {
            guard !voted else { return }
            Haptics.selection()
            withAnimation(LokaAnimation.smooth) {
                votes[index] += 1
                selected = index
            }
        } label: {
            ZStack(alignment: .leading) {
                // result fill
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: LokaCorner.sm, style: .continuous)
                        .fill(isChoice ? LokaColor.brand.opacity(0.25) : LokaColor.surface)
                        .frame(width: voted ? max(geo.size.width * fraction, 8) : geo.size.width)
                }
                HStack {
                    Text(text)
                        .font(LokaFont.callout)
                        .foregroundStyle(LokaColor.textPrimary)
                    if isChoice {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(LokaColor.brand)
                    }
                    Spacer()
                    if voted {
                        Text("\(Int((fraction * 100).rounded()))%")
                            .font(LokaFont.captionEmphasized)
                            .foregroundStyle(LokaColor.textSecondary)
                    }
                }
                .padding(.horizontal, LokaSpacing.md)
            }
            .frame(height: 44)
            .background(voted ? Color.clear : LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LokaCorner.sm, style: .continuous)
                    .strokeBorder(LokaColor.border, lineWidth: voted ? 0 : 1)
            )
        }
        .buttonStyle(PressableButtonStyle(scale: 0.98))
        .disabled(voted || !interactive)
    }
}
