import SwiftUI

// MARK: - Model

/// One entry on a ``ShadBreadcrumbPath``.
///
/// The identity is stable across renames, so a crumb held onto before a
/// ``ShadBreadcrumbPath/rename(_:to:)`` still names the same level afterwards.
public struct ShadCrumb: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var icon: ShadIcon?

    public init(_ title: String, icon: ShadIcon? = nil) {
        self.id = UUID()
        self.title = title
        self.icon = icon
    }
}

/// The stack behind a breadcrumb trail: push a crumb as you descend, pop as you
/// come back up.
///
/// ```swift
/// @StateObject private var path = ShadBreadcrumbPath("Home")
///
/// var body: some View {
///     VStack {
///         ShadBreadcrumb(path: path)
///         ShadButton("Open Components") { path.push("Components") }
///     }
/// }
/// ```
///
/// Clicking a crumb in the rendered trail pops everything after it, so the
/// stack follows the trail without any extra wiring. Give
/// ``ShadBreadcrumb/init(path:maxVisible:onNavigate:)`` an `onNavigate` closure
/// to learn where the user went.
///
/// The root crumb is never popped: ``pop()`` and friends stop there, which
/// keeps the trail from emptying out from under the view.
@MainActor
public final class ShadBreadcrumbPath: ObservableObject {
    /// Every crumb, root first.
    @Published public private(set) var crumbs: [ShadCrumb]

    public init(_ crumbs: [ShadCrumb]) {
        self.crumbs = crumbs
    }

    /// Starts a path from a list of titles, root first.
    public convenience init(_ titles: String...) {
        self.init(titles.map { ShadCrumb($0) })
    }

    // MARK: Reading

    /// The deepest crumb — where the user is now.
    public var current: ShadCrumb? { crumbs.last }

    /// The crumb the trail starts from.
    public var root: ShadCrumb? { crumbs.first }

    /// How deep the trail runs. A path at its root has a depth of 1.
    public var depth: Int { crumbs.count }

    /// Whether there is anywhere left to go back to.
    public var canPop: Bool { crumbs.count > 1 }

    // MARK: Pushing

    /// Descends one level.
    public func push(_ crumb: ShadCrumb) {
        crumbs.append(crumb)
    }

    /// Descends one level, by title.
    public func push(_ title: String, icon: ShadIcon? = nil) {
        push(ShadCrumb(title, icon: icon))
    }

    // MARK: Popping

    /// Goes back up one level.
    ///
    /// - Returns: The crumb that was removed, or `nil` at the root.
    @discardableResult
    public func pop() -> ShadCrumb? {
        pop(1).first
    }

    /// Goes back up `count` levels, stopping at the root.
    ///
    /// - Returns: The crumbs that were removed, deepest last.
    @discardableResult
    public func pop(_ count: Int) -> [ShadCrumb] {
        let removable = min(max(count, 0), max(crumbs.count - 1, 0))
        guard removable > 0 else { return [] }
        let removed = Array(crumbs.suffix(removable))
        crumbs.removeLast(removable)
        return removed
    }

    /// Goes back up to `crumb`, making it the current page.
    ///
    /// Does nothing if the crumb is not on the path — including when it is
    /// already the current one.
    ///
    /// - Returns: The crumbs that were removed, deepest last.
    @discardableResult
    public func pop(to crumb: ShadCrumb) -> [ShadCrumb] {
        guard let index = crumbs.firstIndex(where: { $0.id == crumb.id }) else { return [] }
        return pop(crumbs.count - 1 - index)
    }

    /// Goes back up to the level at `index`, counting from the root.
    @discardableResult
    public func pop(toIndex index: Int) -> [ShadCrumb] {
        guard crumbs.indices.contains(index) else { return [] }
        return pop(crumbs.count - 1 - index)
    }

    /// Goes all the way back to the root.
    @discardableResult
    public func popToRoot() -> [ShadCrumb] {
        pop(crumbs.count - 1)
    }

    // MARK: Editing

    /// Replaces the current crumb — moving sideways rather than deeper.
    public func replaceCurrent(with crumb: ShadCrumb) {
        guard !crumbs.isEmpty else { return push(crumb) }
        crumbs[crumbs.count - 1] = crumb
    }

    /// Renames a crumb in place, keeping its identity.
    public func rename(_ crumb: ShadCrumb, to title: String) {
        guard let index = crumbs.firstIndex(where: { $0.id == crumb.id }) else { return }
        crumbs[index].title = title
    }

    /// Throws the whole trail away and starts again.
    public func reset(to crumbs: [ShadCrumb]) {
        self.crumbs = crumbs
    }
}

// MARK: - Path-driven view

extension ShadBreadcrumb where Content == ShadBreadcrumbPathList {
    /// Renders a ``ShadBreadcrumbPath``, popping back to whichever crumb the
    /// user clicks.
    ///
    /// - Parameters:
    ///   - path: The stack to draw.
    ///   - maxVisible: How many crumbs to show before an ellipsis stands in for
    ///     the middle of the trail. The root and the deepest crumbs are the
    ///     ones kept. Collapsing only happens when it hides more than one
    ///     crumb — swapping a single name for an ellipsis saves no room — so a
    ///     trail may run one crumb longer than this. `nil` never collapses.
    ///   - onNavigate: Called with the crumb the user moved back to, after the
    ///     path has been popped.
    public init(
        path: ShadBreadcrumbPath,
        maxVisible: Int? = nil,
        onNavigate: ((ShadCrumb) -> Void)? = nil
    ) {
        self.init {
            ShadBreadcrumbPathList(
                path: path,
                maxVisible: maxVisible,
                onNavigate: onNavigate
            )
        }
    }
}

/// The list a ``ShadBreadcrumb`` builds from a ``ShadBreadcrumbPath``.
public struct ShadBreadcrumbPathList: View {
    @ObservedObject private var path: ShadBreadcrumbPath
    private let maxVisible: Int?
    private let onNavigate: ((ShadCrumb) -> Void)?

    init(
        path: ShadBreadcrumbPath,
        maxVisible: Int?,
        onNavigate: ((ShadCrumb) -> Void)?
    ) {
        self.path = path
        self.maxVisible = maxVisible
        self.onNavigate = onNavigate
    }

    /// What the list draws, once the middle has been collapsed.
    private enum Entry: Hashable {
        case crumb(ShadCrumb)
        case ellipsis
    }

    private var entries: [Entry] {
        let crumbs = path.crumbs
        // Collapsing only pays off once the ellipsis replaces more than the one
        // crumb it takes the place of.
        guard let maxVisible, maxVisible >= 2, crumbs.count > maxVisible + 1 else {
            return crumbs.map(Entry.crumb)
        }
        // The root, the ellipsis, then as much of the tail as fits.
        let tail = crumbs.suffix(maxVisible - 1)
        return [.crumb(crumbs[0]), .ellipsis] + tail.map(Entry.crumb)
    }

    public var body: some View {
        let entries = entries
        ShadBreadcrumbList {
            ForEach(Array(entries.enumerated()), id: \.element) { index, entry in
                switch entry {
                case .ellipsis:
                    ShadBreadcrumbEllipsis()
                case .crumb(let crumb):
                    if crumb.id == path.current?.id {
                        ShadBreadcrumbPage(crumb.title, icon: crumb.icon)
                    } else {
                        ShadBreadcrumbLink(crumb.title, icon: crumb.icon) {
                            path.pop(to: crumb)
                            onNavigate?(crumb)
                        }
                    }
                }
                if index < entries.count - 1 {
                    ShadBreadcrumbSeparator()
                }
            }
        }
    }
}
