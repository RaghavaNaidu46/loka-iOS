import SwiftUI
import MapKit

/// Shows civic issues as pins at their real locations across Andhra Pradesh &
/// Telangana. Pins are always individual; a separate count "beak" clusters by
/// on-screen proximity (so it merges when zoomed out and splits as you zoom in)
/// and floats above the group it counts. Tapping a pin opens a preview card.
struct MapView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = MapViewModel()

    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: LokaRegion.mapCenter.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: LokaRegion.mapSpanDegrees, longitudeDelta: LokaRegion.mapSpanDegrees)
        )
    )
    @State private var selected: IssueAnnotation?
    @State private var beaks: [AreaCount] = []

    /// Pins closer than this on screen (points) are counted in one beak.
    private let clusterRadius: CGFloat = 48

    /// Keep the camera within Andhra Pradesh + Telangana (can't pan/zoom away).
    private static let cameraBounds = MapCameraBounds(
        centerCoordinateBounds: MKCoordinateRegion(
            center: LokaRegion.mapCenter.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 8.5, longitudeDelta: 8.5)
        ),
        maximumDistance: 2_200_000
    )

    /// A large rectangle with the two states cut out (as holes), so only the
    /// area outside their real borders is shaded.
    private static var dimMask: MKPolygon {
        let outer = [
            CLLocationCoordinate2D(latitude: 26, longitude: 68),
            CLLocationCoordinate2D(latitude: 26, longitude: 95),
            CLLocationCoordinate2D(latitude: 5, longitude: 95),
            CLLocationCoordinate2D(latitude: 5, longitude: 68)
        ]
        let holes = RegionBorders.rings.map { MKPolygon(coordinates: $0, count: $0.count) }
        return MKPolygon(coordinates: outer, count: outer.count, interiorPolygons: holes)
    }

    var body: some View {
        NavigationStack(path: $router.mapPath) {
            MapReader { proxy in
                Map(position: $camera, bounds: Self.cameraBounds) {
                    // Shade everything outside the real AP + Telangana borders.
                    MapPolygon(Self.dimMask)
                        .foregroundStyle(.black.opacity(0.34))
                    ForEach(viewModel.annotations) { item in
                        Annotation(item.issue.title, coordinate: item.coordinate) {
                            pin(for: item)
                        }
                        .annotationTitles(.hidden)
                    }
                    // Count beaks cluster by on-screen proximity; pins unchanged.
                    ForEach(beaks) { area in
                        Annotation("", coordinate: area.coordinate) {
                            countBeak(area.count)
                        }
                        .annotationTitles(.hidden)
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .onMapCameraChange(frequency: .onEnd) { _ in recluster(proxy) }
                .onChange(of: viewModel.annotations.count) { _, _ in recluster(proxy) }
                .ignoresSafeArea(edges: .top)
                .overlay(alignment: .top) { header }
                .overlay(alignment: .bottom) { previewCard }
                .navigationDestination(for: IssueRoute.self) { route in
                    switch route {
                    case .detail(let id): IssueDetailView(issueId: id)
                    }
                }
                .task {
                    if viewModel.issues.isEmpty { await viewModel.load() }
                    recluster(proxy)
                }
            }
        }
    }

    // MARK: - Clustering (screen-space, accurate at any zoom)

    private func recluster(_ proxy: MapProxy) {
        // Project each pin to a screen point (nil = off-screen, skipped).
        let points: [(pt: CGPoint, coord: CLLocationCoordinate2D)] = viewModel.annotations.compactMap {
            guard let p = proxy.convert($0.coordinate, to: .local) else { return nil }
            return (p, $0.coordinate)
        }

        var used = [Bool](repeating: false, count: points.count)
        var result: [AreaCount] = []
        for i in points.indices where !used[i] {
            used[i] = true
            var coords = [points[i].coord]
            for j in points.indices where j > i && !used[j] {
                if hypot(points[i].pt.x - points[j].pt.x, points[i].pt.y - points[j].pt.y) < clusterRadius {
                    used[j] = true
                    coords.append(points[j].coord)
                }
            }
            guard coords.count > 1 else { continue }   // a lone pin gets no beak
            let lat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
            let lon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
            result.append(AreaCount(id: "c\(i)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), count: coords.count))
        }
        beaks = result
    }

    // MARK: - Pins

    private func pin(for item: IssueAnnotation) -> some View {
        let isSelected = selected?.id == item.id
        return Image(systemName: item.issue.category.systemImage)
            .font(.system(size: isSelected ? 18 : 14, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: isSelected ? 46 : 36, height: isSelected ? 46 : 36)
            .background(item.issue.category.tint, in: Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: 2.5))
            .lokaShadow(.card)
            .scaleEffect(isSelected ? 1.05 : 1)
            .animation(LokaAnimation.snappy, value: isSelected)
            .onTapGesture {
                Haptics.selection()
                withAnimation(LokaAnimation.snappy) {
                    selected = item
                    camera = .region(MKCoordinateRegion(
                        center: item.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
                    ))
                }
            }
    }

    // MARK: - Count beak

    private func countBeak(_ count: Int) -> some View {
        VStack(spacing: -1) {
            Text("\(count)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(LokaColor.brand))
                .overlay(Capsule().strokeBorder(.white, lineWidth: 1.5))
            CountBeakTail()
                .fill(LokaColor.brand)
                .frame(width: 10, height: 6)
        }
        .lokaShadow(.card)
        .offset(y: -34)              // float above the pin stack
        .allowsHitTesting(false)     // never intercept taps meant for the pins
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: LokaSpacing.md) {
            BrandMark(size: 36, onGradient: false)
            VStack(alignment: .leading, spacing: 1) {
                Text("Issue map")
                    .font(LokaFont.headingSmall)
                    .foregroundStyle(LokaColor.textPrimary)
                Text("\(viewModel.annotations.count) issues across AP & Telangana")
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textSecondary)
            }
            Spacer()
        }
        .padding(LokaSpacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 0.5))
        .padding(.horizontal, LokaSpacing.lg)
        .padding(.top, LokaSpacing.xs)
    }

    // MARK: - Preview card

    @ViewBuilder
    private var previewCard: some View {
        if let item = selected {
            Button {
                router.mapPath.append(IssueRoute.detail(id: item.issue.id))
            } label: {
                HStack(spacing: LokaSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                            .fill(item.issue.category.tint.opacity(0.16))
                            .frame(width: 48, height: 48)
                        Image(systemName: item.issue.category.systemImage)
                            .font(.system(size: LokaSize.iconMedium, weight: .semibold))
                            .foregroundStyle(item.issue.category.tint)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.issue.title)
                            .font(LokaFont.calloutEmphasized)
                            .foregroundStyle(LokaColor.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: LokaSpacing.xs) {
                            Image(systemName: "mappin.and.ellipse").font(.system(size: 10))
                            Text(item.issue.location.displayText).lineLimit(1)
                            Text("·")
                            Image(systemName: "hand.thumbsup.fill")
                            Text("\(item.issue.supportCount)")
                        }
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.textSecondary)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(LokaColor.textTertiary)
                }
                .padding(LokaSpacing.md)
                .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 0.5))
                .lokaShadow(.floating)
            }
            .buttonStyle(PressableButtonStyle())
            .overlay(alignment: .topTrailing) {
                Button {
                    withAnimation(LokaAnimation.snappy) { selected = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(LokaColor.textTertiary)
                        .padding(6)
                }
            }
            .padding(.horizontal, LokaSpacing.lg)
            .padding(.bottom, LokaSize.tabBarClearance)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

/// Small downward triangle beneath the count badge, pointing at the area.
private struct CountBeakTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    MapView().environmentObject(AppRouter())
}
