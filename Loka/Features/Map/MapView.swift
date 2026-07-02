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
            span: MKCoordinateSpan(latitudeDelta: 9, longitudeDelta: 9)
        )
    )
    @State private var selected: IssueAnnotation?
    /// Current zoom (latitude span, degrees); pins shrink as this grows.
    @State private var span: Double = 9

    /// Pins are full size when zoomed in, ~0.65× when zoomed out.
    private var pinScale: CGFloat {
        let t = min(max((span - 1.0) / 8.0, 0), 1)   // 0 zoomed in … 1 zoomed out
        return 1.0 - 0.35 * t
    }
    @State private var beaks: [AreaCount] = []

    /// Pins closer than this on screen (points) are counted in one beak.
    private let clusterRadius: CGFloat = 48

    /// Keep the camera within Andhra Pradesh + Telangana (smooth hard containment).
    private static let cameraBounds = MapCameraBounds(
        centerCoordinateBounds: MKCoordinateRegion(
            center: LokaRegion.mapCenter.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 8.5, longitudeDelta: 8.5)
        ),
        maximumDistance: 2_800_000
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
        // Decimate the border rings (~1000 → ~250 pts) so the overlay is cheap
        // to re-render while panning/zooming; the edge stays visually accurate.
        let holes = RegionBorders.rings.map { ring -> MKPolygon in
            let pts = stride(from: 0, to: ring.count, by: 4).map { ring[$0] }
            return MKPolygon(coordinates: pts, count: pts.count)
        }
        return MKPolygon(coordinates: outer, count: outer.count, interiorPolygons: holes)
    }

    var body: some View {
        NavigationStack(path: $router.mapPath) {
            MapReader { proxy in
                Map(position: $camera, bounds: Self.cameraBounds) {
                    // Shade outside the real borders. Geo-anchored so it moves
                    // with the map (no lag); labels stay above it (MapKit limit).
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
                        // `.bottom` anchor floats the beak above the point AND keeps
                        // its tap target on the content (an offset would not be tappable).
                        Annotation("", coordinate: area.coordinate, anchor: .bottom) {
                            countBeak(area.count, at: area.coordinate)
                        }
                        .annotationTitles(.hidden)
                    }
                    // "Coming soon" teasers in the shaded neighbouring states.
                    ForEach(Self.comingSoon) { place in
                        Annotation("", coordinate: place.coordinate) {
                            comingSoonBadge(place.name)
                        }
                        .annotationTitles(.hidden)
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                // Update zoom-dependent state only when the gesture ends (no
                // per-frame work while zooming). Pins animate to their new size.
                .onMapCameraChange(frequency: .onEnd) { context in
                    span = context.region.span.latitudeDelta
                    recluster(proxy)
                }
                .onChange(of: viewModel.annotations.count) { _, _ in recluster(proxy) }
                .ignoresSafeArea(edges: .top)
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
        let diameter = (isSelected ? 46 : 36) * pinScale
        let iconSize = (isSelected ? 18 : 14) * pinScale
        return Image(systemName: item.issue.category.systemImage)
            .font(.system(size: iconSize, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: diameter, height: diameter)
            .background(item.issue.category.tint, in: Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: max(2.5 * pinScale, 1.6)))
            .animation(LokaAnimation.snappy, value: pinScale)
            .animation(LokaAnimation.snappy, value: isSelected)
            .onTapGesture {
                Haptics.selection()
                selected = item
                setSpan(0.18, at: item.coordinate)   // zoom right in on the pin
            }
    }

    private func setSpan(_ delta: Double, at coordinate: CLLocationCoordinate2D) {
        withAnimation(LokaAnimation.smooth) {
            camera = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            ))
        }
    }

    // MARK: - "Coming soon" teasers

    private struct ComingSoonPlace: Identifiable {
        let id: String
        let name: String
        let coordinate: CLLocationCoordinate2D
    }

    /// Neighbouring states shown (dimmed) around the region.
    private static let comingSoon: [ComingSoonPlace] = [
        ComingSoonPlace(id: "mh", name: "Maharashtra", coordinate: CLLocationCoordinate2D(latitude: 18.9, longitude: 76.4)),
        ComingSoonPlace(id: "ka", name: "Karnataka", coordinate: CLLocationCoordinate2D(latitude: 14.5, longitude: 75.9)),
        ComingSoonPlace(id: "tn", name: "Tamil Nadu", coordinate: CLLocationCoordinate2D(latitude: 12.7, longitude: 79.3)),
        ComingSoonPlace(id: "od", name: "Odisha", coordinate: CLLocationCoordinate2D(latitude: 19.6, longitude: 83.9)),
        ComingSoonPlace(id: "cg", name: "Chhattisgarh", coordinate: CLLocationCoordinate2D(latitude: 19.8, longitude: 81.2))
    ]

    private func comingSoonBadge(_ name: String) -> some View {
        HStack(spacing: 6) {
            BrandMark(size: 22, onGradient: false)
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("We're coming")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule().fill(.black.opacity(0.5)))
        .overlay(Capsule().strokeBorder(.white.opacity(0.28), lineWidth: 1))
        .allowsHitTesting(false)
    }

    // MARK: - Count beak

    private func countBeak(_ count: Int, at coordinate: CLLocationCoordinate2D) -> some View {
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
        .padding(.bottom, 6)         // small gap above the pin stack
        .contentShape(Rectangle())
        .onTapGesture {              // tap a cluster to zoom close in on it
            Haptics.impact(.light)
            setSpan(0.35, at: coordinate)
        }
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
