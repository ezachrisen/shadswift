import SwiftUI

/// Avatar sizes. `default` is 32pt, matching shadcn's `size-8`.
public enum ShadAvatarSize: String, CaseIterable, Sendable {
    case sm
    case `default`
    case lg

    public var points: CGFloat {
        switch self {
        case .sm: return 24
        case .default: return 32
        case .lg: return 40
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .sm: return 10
        case .default: return 12
        case .lg: return 14
        }
    }
}

/// Where an ``ShadAvatarBadge`` sits.
public enum ShadAvatarBadgeAlignment: Sendable, Hashable {
    case bottomTrailing
    case topTrailing
    case bottomLeading
    case topLeading

    var unitPoint: UnitPoint {
        switch self {
        case .bottomTrailing: return .bottomTrailing
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .topLeading: return .topLeading
        }
    }

    var alignment: Alignment {
        switch self {
        case .bottomTrailing: return .bottomTrailing
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .topLeading: return .topLeading
        }
    }
}

extension ShadButtonShape {
    /// The corner radius an avatar of this shape uses. Shared with
    /// ``ShadAvatarCropper`` and ``ShadEditableAvatar`` so the mask, the
    /// hover scrim and the drop ring cannot drift apart.
    func avatarCornerRadius(_ radius: ShadRadius) -> CGFloat {
        switch self {
        case .pill: return radius.full
        case .rounded: return radius.md
        case .square: return 0
        }
    }
}

/// The source of an avatar's picture.
public enum ShadAvatarImage: Sendable {
    case none
    case url(URL)
    case resource(String)
    case symbol(ShadIcon)
}

/// An image element with a fallback for representing a user.
///
/// ```swift
/// ShadAvatar(fallback: "CN")
/// ShadAvatar(image: .url(url), fallback: "EV", size: .lg)
/// ShadAvatar(fallback: "SC")
///     .badge(color: .green)
/// ```
public struct ShadAvatar: View {
    @Environment(\.shadTheme) private var theme

    private let image: ShadAvatarImage
    private let photo: ShadAvatarPhoto?
    private let fallback: String
    private let size: ShadAvatarSize
    private let customSize: CGFloat?
    private let shape: ShadButtonShape
    private var badge: ShadAvatarBadgeSpec?
    @Environment(\.shadAvatarRingColor) private var ringColor

    public init(
        image: ShadAvatarImage = .none,
        fallback: String = "",
        size: ShadAvatarSize = .default,
        customSize: CGFloat? = nil,
        shape: ShadButtonShape = .pill
    ) {
        self.image = image
        self.photo = nil
        self.fallback = fallback
        self.size = size
        self.customSize = customSize
        self.shape = shape
    }

    /// An avatar showing a cropped ``ShadAvatarPhoto``.
    ///
    /// The crop is resolution-independent, so one photo renders the same
    /// framing at every size the avatar is drawn at.
    public init(
        photo: ShadAvatarPhoto,
        fallback: String = "",
        size: ShadAvatarSize = .default,
        customSize: CGFloat? = nil,
        shape: ShadButtonShape = .pill
    ) {
        self.image = .none
        self.photo = photo
        self.fallback = fallback
        self.size = size
        self.customSize = customSize
        self.shape = shape
    }

    private var side: CGFloat { customSize ?? size.points }

    private var cornerRadius: CGFloat { shape.avatarCornerRadius(theme.radius) }

    /// Adds a status indicator, shadcn's `AvatarBadge`.
    public func badge(
        color: Color? = nil,
        icon: ShadIcon? = nil,
        alignment: ShadAvatarBadgeAlignment = .bottomTrailing
    ) -> ShadAvatar {
        var copy = self
        copy.badge = ShadAvatarBadgeSpec(color: color, icon: icon, alignment: alignment)
        return copy
    }

    public var body: some View {
        ZStack {
            fallbackView
            imageView
        }
        .frame(width: side, height: side)
        .clipShape(ShadRoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            if let ringColor {
                ShadRoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(ringColor, lineWidth: 2)
            }
        }
        .overlay(alignment: badge?.alignment.alignment ?? .bottomTrailing) {
            if let badge {
                ShadAvatarBadge(
                    color: badge.color ?? theme.colors.primary,
                    icon: badge.icon,
                    diameter: max(8, side * 0.32)
                )
                .offset(
                    x: badge.alignment == .bottomTrailing || badge.alignment == .topTrailing ? 2 : -2,
                    y: badge.alignment == .bottomTrailing || badge.alignment == .bottomLeading ? 2 : -2
                )
            }
        }
    }

    @ViewBuilder
    private var fallbackView: some View {
        ShadRoundedRectangle(cornerRadius: cornerRadius)
            .fill(theme.colors.muted)
            .overlay {
                if fallback.isEmpty {
                    ShadIconView(.user, size: side * 0.5)
                        .foregroundStyle(theme.colors.mutedForeground)
                } else {
                    Text(fallback)
                        .font(theme.font(customSize.map { $0 * 0.375 } ?? size.fontSize, theme.typography.medium))
                        .foregroundStyle(theme.colors.mutedForeground)
                }
            }
    }

    @ViewBuilder
    private var imageView: some View {
        if let photo, !photo.isEmpty {
            ShadAvatarPhotoLayer(photo: photo, side: side)
        } else {
            sourceImageView
        }
    }

    @ViewBuilder
    private var sourceImageView: some View {
        switch image {
        case .none:
            EmptyView()
        case .url(let url):
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.clear
                }
            }
        case .resource(let name):
            if let nsImage = NSImage(named: name) {
                Image(nsImage: nsImage).resizable().scaledToFill()
            } else {
                Color.clear
            }
        case .symbol(let icon):
            ShadRoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.colors.secondary)
                .overlay {
                    ShadIconView(icon, size: side * 0.5)
                        .foregroundStyle(theme.colors.secondaryForeground)
                }
        }
    }
}

struct ShadAvatarBadgeSpec {
    var color: Color?
    var icon: ShadIcon?
    var alignment: ShadAvatarBadgeAlignment
}

/// The dot (or tiny icon) drawn on top of an avatar.
public struct ShadAvatarBadge: View {
    @Environment(\.shadTheme) private var theme
    private let color: Color
    private let icon: ShadIcon?
    private let diameter: CGFloat

    public init(color: Color, icon: ShadIcon? = nil, diameter: CGFloat = 10) {
        self.color = color
        self.icon = icon
        self.diameter = diameter
    }

    public var body: some View {
        Circle()
            .fill(color)
            .overlay {
                if let icon {
                    ShadIconView(icon, size: diameter * 0.6)
                        .foregroundStyle(theme.colors.background)
                }
            }
            .frame(width: diameter, height: diameter)
            .overlay(Circle().strokeBorder(theme.colors.background, lineWidth: 2))
    }
}

/// A row of overlapping avatars.
///
/// ```swift
/// ShadAvatarGroup {
///     ShadAvatar(fallback: "CN")
///     ShadAvatar(fallback: "LR")
///     ShadAvatarGroupCount(3)
/// }
/// ```
public struct ShadAvatarGroup<Content: View>: View {
    @Environment(\.shadTheme) private var theme
    private let overlap: CGFloat
    private let content: Content

    public init(overlap: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.overlap = overlap
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: -overlap) {
            content
        }
        .shadAvatarRinged(theme: theme)
    }
}

extension View {
    /// Draws the background-coloured ring that separates stacked avatars.
    fileprivate func shadAvatarRinged(theme: ShadTheme) -> some View {
        environment(\.shadAvatarRingColor, theme.colors.background)
    }
}

private struct ShadAvatarRingColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

extension EnvironmentValues {
    var shadAvatarRingColor: Color? {
        get { self[ShadAvatarRingColorKey.self] }
        set { self[ShadAvatarRingColorKey.self] = newValue }
    }
}

/// The "+3" chip that closes an ``ShadAvatarGroup``.
public struct ShadAvatarGroupCount: View {
    @Environment(\.shadTheme) private var theme
    private let count: Int
    private let size: ShadAvatarSize

    public init(_ count: Int, size: ShadAvatarSize = .default) {
        self.count = count
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(theme.colors.muted)
            .overlay {
                Text("+\(count)")
                    .font(theme.font(size.fontSize, theme.typography.medium))
                    .foregroundStyle(theme.colors.mutedForeground)
            }
            .frame(width: size.points, height: size.points)
            .overlay(Circle().strokeBorder(theme.colors.background, lineWidth: 2))
    }
}
