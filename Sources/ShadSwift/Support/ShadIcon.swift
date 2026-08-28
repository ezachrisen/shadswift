import SwiftUI

/// The icon set used by the library.
///
/// These are the real [Lucide](https://lucide.dev) glyphs — the pack shadcn/ui
/// draws from — vectorised from the upstream SVGs and stroked natively, so an
/// icon's weight matches the text beside it rather than following SF Symbols'
/// heavier optical sizing.
///
/// ``ShadIcon/lucide(_:)`` reaches any bundled glyph by its Lucide name, and
/// ``ShadIcon/custom(_:)`` falls back to an SF Symbol for anything else.
public enum ShadIcon: Hashable, Sendable {
    case check
    case chevronDown
    case chevronUp
    case chevronRight
    case chevronLeft
    case chevronsUpDown
    case x
    case plus
    case minus
    case search
    case user
    case users
    case settings
    case bell
    case mail
    case calendar
    case home
    case folder
    case file
    case trash
    case copy
    case pencil
    case share
    case download
    case upload
    case star
    case heart
    case info
    case circleAlert
    case triangleAlert
    case circleCheck
    case circleX
    case circle
    case creditCard
    case logOut
    case moreHorizontal
    case moreVertical
    case panelLeft
    case panelRight
    case arrowUp
    case arrowDown
    case arrowRight
    case arrowLeft
    case arrowUpRight
    case sparkles
    case bot
    case send
    case refresh
    case eye
    case eyeOff
    case lock
    case globe
    case terminal
    case image
    case play
    case pause
    case gitBranch
    case gitPullRequest
    case cloud
    case cloudUpload
    case zap
    case tag
    case bookmark
    case clock
    case filter
    case list
    case grid
    case clipboardList
    case gripVertical
    case loaderCircle
    case slash
    case arrowUpDown
    /// Any other bundled Lucide glyph, by its upstream name.
    case lucide(String)
    /// An SF Symbol, for anything Lucide does not cover.
    case custom(String)

    /// The upstream Lucide name, when this icon is a Lucide glyph.
    public var lucideName: String? {
        switch self {
        case .check: return "check"
        case .chevronDown: return "chevron-down"
        case .chevronUp: return "chevron-up"
        case .chevronRight: return "chevron-right"
        case .chevronLeft: return "chevron-left"
        case .chevronsUpDown: return "chevrons-up-down"
        case .x: return "x"
        case .plus: return "plus"
        case .minus: return "minus"
        case .search: return "search"
        case .user: return "user"
        case .users: return "users"
        case .settings: return "settings"
        case .bell: return "bell"
        case .mail: return "mail"
        case .calendar: return "calendar"
        case .home: return "house"
        case .folder: return "folder"
        case .file: return "file"
        case .trash: return "trash-2"
        case .copy: return "copy"
        case .pencil: return "pencil"
        case .share: return "share"
        case .download: return "download"
        case .upload: return "upload"
        case .star: return "star"
        case .heart: return "heart"
        case .info: return "info"
        case .circleAlert: return "circle-alert"
        case .triangleAlert: return "triangle-alert"
        case .circleCheck: return "circle-check"
        case .circleX: return "circle-x"
        case .circle: return "circle"
        case .creditCard: return "credit-card"
        case .logOut: return "log-out"
        case .moreHorizontal: return "ellipsis"
        case .moreVertical: return "ellipsis-vertical"
        case .panelLeft: return "panel-left"
        case .panelRight: return "panel-right"
        case .arrowUp: return "arrow-up"
        case .arrowDown: return "arrow-down"
        case .arrowRight: return "arrow-right"
        case .arrowLeft: return "arrow-left"
        case .arrowUpRight: return "arrow-up-right"
        case .sparkles: return "sparkles"
        case .bot: return "bot"
        case .send: return "send"
        case .refresh: return "refresh-cw"
        case .eye: return "eye"
        case .eyeOff: return "eye-off"
        case .lock: return "lock"
        case .globe: return "globe"
        case .terminal: return "terminal"
        case .image: return "image"
        case .play: return "play"
        case .pause: return "pause"
        case .gitBranch: return "git-branch"
        case .gitPullRequest: return "git-pull-request"
        case .cloud: return "cloud"
        case .cloudUpload: return "cloud-upload"
        case .zap: return "zap"
        case .tag: return "tag"
        case .bookmark: return "bookmark"
        case .clock: return "clock"
        case .filter: return "funnel"
        case .list: return "list"
        case .grid: return "layout-grid"
        case .clipboardList: return "clipboard-list"
        case .gripVertical: return "grip-vertical"
        case .loaderCircle: return "loader-circle"
        case .slash: return "slash"
        case .arrowUpDown: return "arrow-up-down"
        case .lucide(let name): return name
        case .custom: return nil
        }
    }

    /// The SF Symbol used when the glyph is not part of the bundled set.
    public var systemName: String? {
        if case .custom(let name) = self { return name }
        return nil
    }

    var commands: [ShadVectorCommand]? {
        guard let lucideName else { return nil }
        return ShadLucideData.icons[lucideName]
    }
}

/// Renders a ``ShadIcon`` at a fixed point size.
///
/// Lucide glyphs are stroked at 2 units in a 24-unit grid, scaled to the
/// requested size, with round caps and joins — the upstream defaults.
public struct ShadIconView: View {
    private let icon: ShadIcon
    private let size: CGFloat
    private let weight: Font.Weight
    private let strokeWidth: CGFloat?

    public init(_ icon: ShadIcon, size: CGFloat = 16, weight: Font.Weight = .regular, strokeWidth: CGFloat? = nil) {
        self.icon = icon
        self.size = size
        self.weight = weight
        self.strokeWidth = strokeWidth
    }

    /// Lucide's own stroke width, scaled into the requested point size.
    private var resolvedStroke: CGFloat {
        if let strokeWidth { return strokeWidth }
        return 2 * size / 24
    }

    public var body: some View {
        Group {
            if let commands = icon.commands {
                ShadLucideShape(commands: commands)
                    .stroke(style: StrokeStyle(
                        lineWidth: resolvedStroke,
                        lineCap: .round,
                        lineJoin: .round
                    ))
            } else if let systemName = icon.systemName {
                Image(systemName: systemName)
                    .font(.system(size: size, weight: weight))
            }
        }
        .frame(width: size, height: size)
    }
}

extension Image {
    /// `Image(shad: .check)` — an SF Symbol fallback for the rare glyph that is
    /// not in the bundled Lucide set.
    public init?(shad icon: ShadIcon) {
        guard let systemName = icon.systemName else { return nil }
        self.init(systemName: systemName)
    }
}
