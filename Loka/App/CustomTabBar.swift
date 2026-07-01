import SwiftUI

/// A floating, frosted tab bar with an elevated center "Create" action.
/// Drives `AppRouter.selectedTab`.
struct CustomTabBar: View {
    @Binding var selection: AppTab
    /// Whether there are unread notifications (drives the badge dot).
    var hasNotifications: Bool = false

    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.home, icon: "house.fill", label: "Home")
            tabButton(.search, icon: "magnifyingglass", label: "Search")
            createButton
            tabButton(.notifications, icon: "bell.fill", label: "Alerts", showsBadge: hasNotifications)
            tabButton(.profile, icon: "person.fill", label: "Profile")
        }
        .padding(.horizontal, LokaSpacing.sm)
        .padding(.vertical, LokaSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(LokaColor.border, lineWidth: 0.5))
        .lokaShadow(.floating)
        .padding(.horizontal, LokaSpacing.xl)
        .padding(.bottom, LokaSpacing.xs)
    }

    // MARK: - Standard tab

    private func tabButton(_ tab: AppTab, icon: String, label: String, showsBadge: Bool = false) -> some View {
        Button {
            guard selection != tab else { return }
            Haptics.selection()
            withAnimation(LokaAnimation.snappy) { selection = tab }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Image(systemName: icon)
                        .font(.system(size: LokaSize.iconMedium, weight: .semibold))
                        .foregroundStyle(selection == tab ? LokaColor.brand : LokaColor.textTertiary)
                        .scaleEffect(selection == tab ? 1.08 : 1)
                    if showsBadge {
                        Circle()
                            .fill(LokaColor.danger)
                            .frame(width: 8, height: 8)
                            .offset(x: 9, y: -9)
                    }
                }
                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(selection == tab ? LokaColor.brand : LokaColor.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
        .accessibilityLabel(label)
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
    }

    // MARK: - Center create action

    private var createButton: some View {
        Button {
            Haptics.impact(.medium)
            withAnimation(LokaAnimation.bouncy) { selection = .create }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(LokaColor.onBrand)
                .frame(width: 52, height: 52)
                .background(LokaColor.brandGradient, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1))
                .lokaShadow(.card)
                .scaleEffect(selection == .create ? 1.06 : 1)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Create issue")
        .accessibilityAddTraits(selection == .create ? .isSelected : [])
    }
}
