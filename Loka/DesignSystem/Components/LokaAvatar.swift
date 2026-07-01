import SwiftUI

/// Initials-based avatar. The fill color is derived deterministically from the
/// name so the same citizen always gets the same color. Optionally shows a
/// verified seal badge.
struct LokaAvatar: View {
    let name: String
    var size: CGFloat = LokaSize.avatarMedium
    var isVerified: Bool = false

    var body: some View {
        Circle()
            .fill(gradient)
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            )
            .overlay(alignment: .bottomTrailing) {
                if isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: size * 0.34))
                        .foregroundStyle(LokaColor.support)
                        .background(Circle().fill(LokaColor.surface).padding(1))
                        .offset(x: 2, y: 2)
                }
            }
            .accessibilityLabel(isVerified ? "\(name), verified" : name)
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init)
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    private var gradient: LinearGradient {
        let palette: [(UInt32, UInt32)] = [
            (0x7A5AF8, 0x5B3FE0), (0x2E9BD6, 0x1F7BB8), (0x2F9E68, 0x1F7A4E),
            (0xE0A320, 0xC7871B), (0xE0574F, 0xC0463D), (0x2B4EFF, 0x1B2FB8)
        ]
        let index = abs(name.hashValue) % palette.count
        let pair = palette[index]
        return LinearGradient(
            colors: [color(pair.0), color(pair.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func color(_ value: UInt32) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
