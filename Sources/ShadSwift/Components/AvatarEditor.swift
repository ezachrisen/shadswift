import AppKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Crop

/// How a picture is framed inside an avatar's mask.
///
/// Both values are resolution-independent. `zoom` is a multiple of the scale
/// that makes the picture exactly fill the mask, and `offset` is measured in
/// fractions of the mask's width — so the crop a user chooses in a 196pt
/// editor reads identically on the 32pt avatar in a comment thread.
public struct ShadAvatarCrop: Sendable, Hashable {
    /// `1` fills the mask; larger values zoom in.
    public var zoom: Double
    /// Pan away from centre, in fractions of the mask's width.
    public var offset: CGSize

    public init(zoom: Double = 1, offset: CGSize = .zero) {
        self.zoom = zoom
        self.offset = offset
    }

    /// Centred, and zoomed just enough to fill the mask.
    public static let fill = ShadAvatarCrop()

    /// The picture's drawn size, in multiples of the mask's width.
    ///
    /// At `zoom` 1 the shorter side measures exactly 1 — an aspect fill — and
    /// the longer side overhangs by the picture's aspect ratio.
    func extent(for imageSize: CGSize) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGSize(width: zoom, height: zoom)
        }
        let aspect = imageSize.width / imageSize.height
        return CGSize(width: max(1, aspect) * zoom, height: max(1, 1 / aspect) * zoom)
    }

    /// How far the picture can be panned before an edge would come into view.
    func panLimit(for imageSize: CGSize) -> CGSize {
        let extent = extent(for: imageSize)
        return CGSize(
            width: max(0, (extent.width - 1) / 2),
            height: max(0, (extent.height - 1) / 2)
        )
    }

    /// ``offset`` pulled back inside ``panLimit(for:)``, so the mask stays
    /// covered however far the user drags.
    func clampedOffset(for imageSize: CGSize) -> CGSize {
        let limit = panLimit(for: imageSize)
        return CGSize(
            width: min(max(offset.width, -limit.width), limit.width),
            height: min(max(offset.height, -limit.height), limit.height)
        )
    }
}

// MARK: - Photo

/// A picture, plus the ``ShadAvatarCrop`` that frames it inside an avatar.
///
/// ```swift
/// ShadAvatar(photo: photo, fallback: "EV", size: .lg)
/// ```
public struct ShadAvatarPhoto {
    /// The picture. `nil` falls back to initials or the placeholder icon.
    public var image: NSImage?
    /// Where the picture sits inside the mask.
    public var crop: ShadAvatarCrop

    public init(image: NSImage? = nil, crop: ShadAvatarCrop = .fill) {
        self.image = image
        self.crop = crop
    }

    /// No picture at all.
    public static let empty = ShadAvatarPhoto()

    public var isEmpty: Bool { image == nil }

    /// Swaps in a new picture, centred and zoomed to fill.
    public mutating func replace(with image: NSImage) {
        self.image = image
        self.crop = .fill
    }

    /// Zooms, keeping the picture over the mask.
    public mutating func zoom(to value: Double) {
        crop.zoom = value
        clampOffset()
    }

    /// Pans, keeping the picture over the mask. `offset` is in fractions of
    /// the mask's width, like ``ShadAvatarCrop/offset``.
    public mutating func pan(to offset: CGSize) {
        crop.offset = offset
        clampOffset()
    }

    private mutating func clampOffset() {
        guard let size = image?.size else {
            crop.offset = .zero
            return
        }
        crop.offset = crop.clampedOffset(for: size)
    }
}

extension ShadAvatarPhoto: Equatable {
    /// Two photos match when they frame the very same image object the same
    /// way. `NSImage` has no value equality, so identity is the only honest
    /// test available.
    public static func == (lhs: ShadAvatarPhoto, rhs: ShadAvatarPhoto) -> Bool {
        lhs.image === rhs.image && lhs.crop == rhs.crop
    }
}

/// Draws a ``ShadAvatarPhoto`` for a mask `side` points across.
///
/// The picture deliberately overflows the returned frame — the caller clips it
/// to the avatar's shape, which is what makes the crop a crop.
struct ShadAvatarPhotoLayer: View {
    let photo: ShadAvatarPhoto
    let side: CGFloat

    var body: some View {
        if let image = photo.image {
            let extent = photo.crop.extent(for: image.size)
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .frame(width: extent.width * side, height: extent.height * side)
                .offset(x: photo.crop.offset.width * side, y: photo.crop.offset.height * side)
                .frame(width: side, height: side)
        }
    }
}

// MARK: - Dropping an image

/// Pulls the first usable picture out of a drag.
///
/// Finder hands over a file URL; a browser or Photos hands over the image
/// itself, so both are worth asking for.
enum ShadImageDrop {
    /// The types a drop target should advertise.
    static let types: [UTType] = [.fileURL, .image]

    /// Returns true when something in `providers` is worth waiting for.
    /// `handler` runs on the main queue once the picture has loaded.
    static func load(
        from providers: [NSItemProvider],
        handler: @escaping (NSImage) -> Void
    ) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    guard let url, let image = NSImage(contentsOf: url) else { return }
                    DispatchQueue.main.async { handler(image) }
                }
                return true
            }
            if provider.canLoadObject(ofClass: NSImage.self) {
                _ = provider.loadObject(ofClass: NSImage.self) { object, _ in
                    guard let image = object as? NSImage else { return }
                    DispatchQueue.main.async { handler(image) }
                }
                return true
            }
        }
        return false
    }
}

/// The open hand shown over a picture that can be dragged.
///
/// It tracks its own push so a dialog that closes under the pointer cannot
/// leave the cursor stuck.
private struct ShadGrabCursor: ViewModifier {
    let isEnabled: Bool
    @State private var isPushed = false

    func body(content: Content) -> some View {
        content
            .onHover { inside in
                if inside, isEnabled, !isPushed {
                    NSCursor.openHand.push()
                    isPushed = true
                } else if (!inside || !isEnabled), isPushed {
                    NSCursor.pop()
                    isPushed = false
                }
            }
            .onDisappear {
                if isPushed {
                    NSCursor.pop()
                    isPushed = false
                }
            }
    }
}

// MARK: - Cropper

/// The framing control: a picture inside the avatar's own mask, a zoom slider
/// under it, and a drop target for a replacement image file.
///
/// Drag the picture to reposition it. The pan is clamped, and re-clamped when
/// the zoom comes back down, so the mask stays covered however far the pointer
/// travels.
///
/// ```swift
/// ShadAvatarCropper(photo: $photo)
/// ```
public struct ShadAvatarCropper: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.shadStaticRendering) private var isStatic

    @Binding private var photo: ShadAvatarPhoto
    private let diameter: CGFloat
    private let shape: ShadButtonShape
    private let zoomRange: ClosedRange<Double>

    @State private var panStart: CGSize?
    @State private var isTargeted = false

    public init(
        photo: Binding<ShadAvatarPhoto>,
        diameter: CGFloat = 196,
        shape: ShadButtonShape = .pill,
        zoomRange: ClosedRange<Double> = 1...3
    ) {
        self._photo = photo
        self.diameter = diameter
        self.shape = shape
        self.zoomRange = zoomRange
    }

    /// The margin of cropped-away picture shown around the mask.
    private var surround: CGFloat { (diameter * 0.11).rounded() }
    private var stageSide: CGFloat { diameter + surround * 2 }
    private var maskRadius: CGFloat { shape.avatarCornerRadius(theme.radius) }

    public var body: some View {
        VStack(spacing: 16) {
            stage
            zoomRow
            hint
        }
        .frame(width: stageSide)
        .animation(theme.interactionAnimation, value: isTargeted)
    }

    // MARK: Stage

    private var stage: some View {
        ZStack {
            theme.colors.muted

            // The picture at full extent, faded back: everything outside the
            // mask is what the crop throws away.
            ShadAvatarPhotoLayer(photo: photo, side: diameter)
                .opacity(0.22)

            maskedPicture
        }
        .frame(width: stageSide, height: stageSide)
        .clipShape(ShadRoundedRectangle(cornerRadius: theme.radius.lg))
        .overlay {
            ShadRoundedRectangle(cornerRadius: theme.radius.lg)
                .strokeBorder(
                    isTargeted ? theme.colors.ring : theme.colors.border,
                    style: StrokeStyle(
                        lineWidth: isTargeted ? 2 : theme.borderWidth,
                        dash: photo.isEmpty && !isTargeted ? [6, 4] : []
                    )
                )
        }
        .contentShape(Rectangle())
        .gesture(panGesture)
        .modifier(ShadGrabCursor(isEnabled: !photo.isEmpty))
        // The drop responder is AppKit-backed, and `ImageRenderer` paints a
        // yellow placeholder over anything it cannot capture. Leave it out
        // while rendering, the way the dialog leaves out its key monitor.
        .shadIf(!isStatic) { view in
            view.onDrop(of: ShadImageDrop.types, isTargeted: $isTargeted) { providers in
                ShadImageDrop.load(from: providers) { image in
                    photo.replace(with: image)
                }
            }
        }
        .accessibilityLabel("Avatar picture")
        .accessibilityHint("Drag to reposition, or drop an image file to replace it")
    }

    private var maskedPicture: some View {
        ZStack {
            ShadRoundedRectangle(cornerRadius: maskRadius)
                .fill(theme.colors.background)

            if photo.isEmpty {
                placeholder
            } else {
                ShadAvatarPhotoLayer(photo: photo, side: diameter)
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(ShadRoundedRectangle(cornerRadius: maskRadius))
        .overlay {
            // A hairline keeps the mask legible where the sharp picture meets
            // the faded one behind it.
            ShadRoundedRectangle(cornerRadius: maskRadius)
                .strokeBorder(theme.colors.background.opacity(0.85), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        VStack(spacing: 10) {
            ShadIconView(isTargeted ? .upload : .image, size: 28)
                .foregroundStyle(theme.colors.mutedForeground)
            Text(isTargeted ? "Drop to use" : "No picture")
                .font(theme.font(theme.typography.sm))
                .foregroundStyle(theme.colors.mutedForeground)
        }
    }

    // MARK: Zoom

    private var zoomBinding: Binding<Double> {
        Binding(
            get: { photo.crop.zoom },
            set: { photo.zoom(to: $0) }
        )
    }

    private var zoomRow: some View {
        HStack(spacing: 12) {
            ShadIconView(.image, size: 12)
                .foregroundStyle(theme.colors.mutedForeground)
            ShadSlider(value: zoomBinding, in: zoomRange)
            ShadIconView(.image, size: 18)
                .foregroundStyle(theme.colors.mutedForeground)
        }
        .disabled(photo.isEmpty)
        .accessibilityLabel("Zoom")
    }

    private var hint: some View {
        Text(photo.isEmpty
             ? "Drag an image file here"
             : "Drag the picture to reposition it")
            .font(theme.font(theme.typography.xs))
            .foregroundStyle(theme.colors.mutedForeground)
    }

    // MARK: Panning

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                guard !photo.isEmpty else { return }
                let start = panStart ?? photo.crop.offset
                if panStart == nil { panStart = start }
                photo.pan(to: CGSize(
                    width: start.width + drag.translation.width / diameter,
                    height: start.height + drag.translation.height / diameter
                ))
            }
            .onEnded { _ in panStart = nil }
    }
}

// MARK: - Editor state

/// Drives an avatar editor: the picture the profile shows, and the copy being
/// framed while the dialog is open.
///
/// Nothing the dialog does touches ``photo`` until Save is pressed, so Cancel
/// — and the Escape key, and a click on the backdrop — put everything back,
/// including a picture that was dropped onto the mask.
///
/// ```swift
/// @State private var avatar = ShadAvatarEditorState()
///
/// ShadEditableAvatar($avatar, fallback: "EV", customSize: 96)
///     .shadAvatarEditor($avatar)
/// ```
public struct ShadAvatarEditorState {
    /// The committed picture — what the profile shows.
    public var photo: ShadAvatarPhoto
    /// True while the editor is open.
    public internal(set) var isEditing: Bool
    /// The copy the dialog is framing.
    var draft: ShadAvatarPhoto

    public init(photo: ShadAvatarPhoto = .empty) {
        self.photo = photo
        self.isEditing = false
        self.draft = photo
    }

    /// Starts from a bare image, framed to fill.
    public init(image: NSImage?) {
        self.init(photo: ShadAvatarPhoto(image: image))
    }

    /// Opens the editor on the current picture.
    public mutating func beginEditing() {
        draft = photo
        isEditing = true
    }

    /// Opens the editor on a replacement picture, centred and zoomed to fill.
    ///
    /// The replacement only reaches ``photo`` if the user saves.
    public mutating func beginEditing(with image: NSImage) {
        draft = ShadAvatarPhoto(image: image)
        isEditing = true
    }

    /// Keeps the framing and closes.
    public mutating func save() {
        photo = draft
        isEditing = false
    }

    /// Throws the draft away and closes.
    public mutating func cancel() {
        draft = photo
        isEditing = false
    }
}

// MARK: - Editor dialog

/// The editor panel: the mask, the zoom slider, and Save / Cancel.
///
/// Present it with ``SwiftUICore/View/shadAvatarEditor(_:title:description:diameter:shape:zoomRange:saveTitle:cancelTitle:onSave:)``
/// rather than building it by hand, unless you need it inside a dialog of your
/// own.
public struct ShadAvatarEditor: View {
    @Binding private var state: ShadAvatarEditorState

    private let title: String
    private let description: String?
    private let diameter: CGFloat
    private let shape: ShadButtonShape
    private let zoomRange: ClosedRange<Double>
    private let saveTitle: String
    private let cancelTitle: String
    private let onSave: ((ShadAvatarPhoto) -> Void)?

    public init(
        _ state: Binding<ShadAvatarEditorState>,
        title: String = "Profile picture",
        description: String? = "Drag the picture to reposition it, and zoom with the slider.",
        diameter: CGFloat = 196,
        shape: ShadButtonShape = .pill,
        zoomRange: ClosedRange<Double> = 1...3,
        saveTitle: String = "Save",
        cancelTitle: String = "Cancel",
        onSave: ((ShadAvatarPhoto) -> Void)? = nil
    ) {
        self._state = state
        self.title = title
        self.description = description
        self.diameter = diameter
        self.shape = shape
        self.zoomRange = zoomRange
        self.saveTitle = saveTitle
        self.cancelTitle = cancelTitle
        self.onSave = onSave
    }

    /// Wide enough for the stage plus the panel's own padding.
    private var maxWidth: CGFloat { max(360, diameter * 1.22 + 96) }

    public var body: some View {
        ShadDialogContent(maxWidth: maxWidth) {
            ShadDialogHeader {
                ShadDialogTitle(title)
                if let description {
                    ShadDialogDescription(description)
                }
            }

            ShadAvatarCropper(
                photo: $state.draft,
                diameter: diameter,
                shape: shape,
                zoomRange: zoomRange
            )
            .frame(maxWidth: .infinity, alignment: .center)
        } footer: {
            ShadButton(cancelTitle, variant: .outline) { state.cancel() }
            ShadButton(saveTitle) {
                let saved = state.draft
                state.save()
                onSave?(saved)
            }
        }
    }
}

extension View {
    /// Presents the avatar editor over this view.
    ///
    /// Attach it where a dialog belongs — the root of the window, or the root
    /// of a page — so the scrim covers everything beneath it:
    ///
    /// ```swift
    /// ProfileView()
    ///     .shadAvatarEditor($avatar)
    /// ```
    public func shadAvatarEditor(
        _ state: Binding<ShadAvatarEditorState>,
        title: String = "Profile picture",
        description: String? = "Drag the picture to reposition it, and zoom with the slider.",
        diameter: CGFloat = 196,
        shape: ShadButtonShape = .pill,
        zoomRange: ClosedRange<Double> = 1...3,
        saveTitle: String = "Save",
        cancelTitle: String = "Cancel",
        onSave: ((ShadAvatarPhoto) -> Void)? = nil
    ) -> some View {
        shadDialog(
            isPresented: Binding(
                get: { state.wrappedValue.isEditing },
                // Escape, the close button and the backdrop all mean cancel.
                set: { if !$0 { state.wrappedValue.cancel() } }
            )
        ) {
            ShadAvatarEditor(
                state,
                title: title,
                description: description,
                diameter: diameter,
                shape: shape,
                zoomRange: zoomRange,
                saveTitle: saveTitle,
                cancelTitle: cancelTitle,
                onSave: onSave
            )
        }
    }
}

// MARK: - Editable avatar

/// An avatar that opens the editor when it is clicked, and takes an image file
/// dropped straight onto it.
///
/// Pair it with ``SwiftUICore/View/shadAvatarEditor(_:title:description:diameter:shape:zoomRange:saveTitle:cancelTitle:onSave:)``
/// on an ancestor, which is what actually presents the dialog:
///
/// ```swift
/// @State private var avatar = ShadAvatarEditorState()
///
/// VStack {
///     ShadEditableAvatar($avatar, fallback: "EV", customSize: 96)
///     Text("Evil Rabbit")
/// }
/// .shadAvatarEditor($avatar)
/// ```
///
/// A dropped file opens the editor on the new picture rather than committing
/// it, so a mis-drop is one Cancel away from being undone.
public struct ShadEditableAvatar: View {
    @Environment(\.shadTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.shadStaticRendering) private var isStatic

    @Binding private var state: ShadAvatarEditorState
    private let fallback: String
    private let size: ShadAvatarSize
    private let customSize: CGFloat?
    private let shape: ShadButtonShape

    @State private var isHovering = false
    @State private var isTargeted = false

    public init(
        _ state: Binding<ShadAvatarEditorState>,
        fallback: String = "",
        size: ShadAvatarSize = .default,
        customSize: CGFloat? = nil,
        shape: ShadButtonShape = .pill
    ) {
        self._state = state
        self.fallback = fallback
        self.size = size
        self.customSize = customSize
        self.shape = shape
    }

    private var side: CGFloat { customSize ?? size.points }
    private var cornerRadius: CGFloat { shape.avatarCornerRadius(theme.radius) }
    private var isHighlighted: Bool { isEnabled && (isHovering || isTargeted) }

    public var body: some View {
        Button {
            state.beginEditing()
        } label: {
            ShadAvatar(
                photo: state.photo,
                fallback: fallback,
                size: size,
                customSize: customSize,
                shape: shape
            )
            .overlay {
                ShadRoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.black.opacity(isHighlighted ? 0.45 : 0))
                    .overlay {
                        ShadIconView(isTargeted ? .upload : .pencil, size: max(12, side * 0.3))
                            .foregroundStyle(.white.opacity(isHighlighted ? 1 : 0))
                    }
            }
            .overlay {
                ShadRoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(theme.colors.ring.opacity(isTargeted ? 1 : 0), lineWidth: 2)
            }
            .animation(theme.interactionAnimation, value: isHighlighted)
            .animation(theme.interactionAnimation, value: isTargeted)
            .contentShape(ShadRoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.shadPlain)
        .focusEffectDisabled()
        .shadHover($isHovering, enabled: isEnabled)
        .shadPointerCursor(isEnabled)
        .shadIf(!isStatic) { view in
            view.onDrop(of: ShadImageDrop.types, isTargeted: $isTargeted) { providers in
                guard isEnabled else { return false }
                return ShadImageDrop.load(from: providers) { image in
                    state.beginEditing(with: image)
                }
            }
        }
        .accessibilityLabel(fallback.isEmpty ? "Profile picture" : "Profile picture for \(fallback)")
        .accessibilityHint("Opens the picture editor. An image file can also be dropped here.")
    }
}
