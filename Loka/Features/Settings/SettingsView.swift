import SwiftUI

/// App settings. In Debug builds this also hosts the "Developer" section with
/// the sample-data toggle.
struct SettingsView: View {
    #if DEBUG
    @StateObject private var debug = DebugSettings.shared
    #endif

    var body: some View {
        ScrollView {
            VStack(spacing: LokaSpacing.xl) {
                infoCard
                #if DEBUG
                developerCard
                #endif
            }
            .padding(LokaSpacing.lg)
            .padding(.bottom, LokaSize.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .background(LokaColor.base)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            row(icon: "info.circle.fill", tint: LokaColor.info, title: "About Loka")
            Divider().overlay(LokaColor.divider).padding(.leading, 56)
            row(icon: "doc.text.fill", tint: LokaColor.textSecondary, title: "Policies")
        }
        .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 0.5))
    }

    private func row(icon: String, tint: Color, title: String) -> some View {
        HStack(spacing: LokaSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LokaCorner.sm, style: .continuous).fill(tint.opacity(0.14)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: LokaSize.iconSmall, weight: .semibold)).foregroundStyle(tint)
            }
            Text(title).font(LokaFont.callout).foregroundStyle(LokaColor.textPrimary)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(LokaColor.textTertiary)
        }
        .padding(LokaSpacing.md)
        .contentShape(Rectangle())
    }

    #if DEBUG
    private var developerCard: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            SectionHeader(title: "Developer", subtitle: "Debug builds only")
            LokaCard {
                Toggle(isOn: $debug.useSampleData) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Load sample feed data")
                            .font(LokaFont.calloutEmphasized)
                            .foregroundStyle(LokaColor.textPrimary)
                        Text("Fills the feed with \(SampleFeed.issues.count) demo posts (text, images, video, links, polls) so you can preview the live look.")
                            .font(LokaFont.caption)
                            .foregroundStyle(LokaColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(LokaColor.brand)
            }
        }
    }
    #endif
}
