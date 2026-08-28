// Generated from the Lucide icon set (https://lucide.dev), ISC licensed.
// Regenerate with Scripts/generate-icons.sh — do not edit by hand.

import Foundation

/// One drawing instruction from a Lucide SVG, in the 24×24 view box.
enum ShadVectorCommand: Sendable {
    case path(String)
    case circle(x: Double, y: Double, r: Double)
    case rect(x: Double, y: Double, width: Double, height: Double, rx: Double, ry: Double)
    case line(x1: Double, y1: Double, x2: Double, y2: Double)
}

/// The Lucide glyphs ShadSwift draws, keyed by their Lucide name.
enum ShadLucideData {
    static let icons: [String: [ShadVectorCommand]] = [
        "arrow-down": [
            .path("M12 5v14"),
            .path("m19 12-7 7-7-7"),
        ],
        "arrow-left": [
            .path("m12 19-7-7 7-7"),
            .path("M19 12H5"),
        ],
        "arrow-right": [
            .path("M5 12h14"),
            .path("m12 5 7 7-7 7"),
        ],
        "arrow-up-down": [
            .path("m21 16-4 4-4-4"),
            .path("M17 20V4"),
            .path("m3 8 4-4 4 4"),
            .path("M7 4v16"),
        ],
        "arrow-up-right": [
            .path("M7 7h10v10"),
            .path("M7 17 17 7"),
        ],
        "arrow-up": [
            .path("m5 12 7-7 7 7"),
            .path("M12 19V5"),
        ],
        "bell": [
            .path("M10.268 21a2 2 0 0 0 3.464 0"),
            .path("M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326"),
        ],
        "bookmark": [
            .path("M17 3a2 2 0 0 1 2 2v15a1 1 0 0 1-1.496.868l-4.512-2.578a2 2 0 0 0-1.984 0l-4.512 2.578A1 1 0 0 1 5 20V5a2 2 0 0 1 2-2z"),
        ],
        "bot": [
            .path("M12 8V4H8"),
            .rect(x: 4.0, y: 8.0, width: 16.0, height: 12.0, rx: 2.0, ry: 2.0),
            .path("M2 14h2"),
            .path("M20 14h2"),
            .path("M15 13v2"),
            .path("M9 13v2"),
        ],
        "calendar": [
            .path("M8 2v3"),
            .path("M16 2v3"),
            .rect(x: 3.0, y: 3.0, width: 18.0, height: 18.0, rx: 2.0, ry: 2.0),
            .path("M3 9h18"),
        ],
        "check": [
            .path("M20 6 9 17l-5-5"),
        ],
        "chevron-down": [
            .path("m6 9 6 6 6-6"),
        ],
        "chevron-left": [
            .path("m15 18-6-6 6-6"),
        ],
        "chevron-right": [
            .path("m9 18 6-6-6-6"),
        ],
        "chevron-up": [
            .path("m18 15-6-6-6 6"),
        ],
        "chevrons-up-down": [
            .path("m7 15 5 5 5-5"),
            .path("m7 9 5-5 5 5"),
        ],
        "circle-alert": [
            .circle(x: 12.0, y: 12.0, r: 10.0),
            .line(x1: 12.0, y1: 8.0, x2: 12.0, y2: 12.0),
            .line(x1: 12.0, y1: 16.0, x2: 12.01, y2: 16.0),
        ],
        "circle-check": [
            .circle(x: 12.0, y: 12.0, r: 10.0),
            .path("m9 12 2 2 4-4"),
        ],
        "circle-x": [
            .circle(x: 12.0, y: 12.0, r: 10.0),
            .path("m15 9-6 6"),
            .path("m9 9 6 6"),
        ],
        "circle": [
            .circle(x: 12.0, y: 12.0, r: 10.0),
        ],
        "clipboard-list": [
            .rect(x: 8.0, y: 2.0, width: 8.0, height: 4.0, rx: 1.0, ry: 1.0),
            .path("M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"),
            .path("M12 11h4"),
            .path("M12 16h4"),
            .path("M8 11h.01"),
            .path("M8 16h.01"),
        ],
        "clock": [
            .circle(x: 12.0, y: 12.0, r: 10.0),
            .path("M12 6v6l4 2"),
        ],
        "cloud-upload": [
            .path("M12 13v8"),
            .path("M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242"),
            .path("m8 17 4-4 4 4"),
        ],
        "cloud": [
            .path("M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"),
        ],
        "copy": [
            .rect(x: 8.0, y: 8.0, width: 14.0, height: 14.0, rx: 2.0, ry: 2.0),
            .path("M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"),
        ],
        "credit-card": [
            .rect(x: 2.0, y: 5.0, width: 20.0, height: 14.0, rx: 2.0, ry: 2.0),
            .line(x1: 2.0, y1: 10.0, x2: 22.0, y2: 10.0),
        ],
        "download": [
            .path("M12 15V3"),
            .path("M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"),
            .path("m7 10 5 5 5-5"),
        ],
        "ellipsis-vertical": [
            .circle(x: 12.0, y: 12.0, r: 1.0),
            .circle(x: 12.0, y: 5.0, r: 1.0),
            .circle(x: 12.0, y: 19.0, r: 1.0),
        ],
        "ellipsis": [
            .circle(x: 12.0, y: 12.0, r: 1.0),
            .circle(x: 19.0, y: 12.0, r: 1.0),
            .circle(x: 5.0, y: 12.0, r: 1.0),
        ],
        "eye-off": [
            .path("M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49"),
            .path("M14.084 14.158a3 3 0 0 1-4.242-4.242"),
            .path("M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143"),
            .path("m2 2 20 20"),
        ],
        "eye": [
            .path("M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"),
            .circle(x: 12.0, y: 12.0, r: 3.0),
        ],
        "file": [
            .path("M6 22a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.704.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2z"),
            .path("M14 2v5a1 1 0 0 0 1 1h5"),
        ],
        "folder": [
            .path("M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"),
        ],
        "funnel": [
            .path("M10 20a1 1 0 0 0 .553.895l2 1A1 1 0 0 0 14 21v-7a2 2 0 0 1 .517-1.341L21.74 4.67A1 1 0 0 0 21 3H3a1 1 0 0 0-.742 1.67l7.225 7.989A2 2 0 0 1 10 14z"),
        ],
        "git-branch": [
            .path("M15 6a9 9 0 0 0-9 9V3"),
            .circle(x: 18.0, y: 6.0, r: 3.0),
            .circle(x: 6.0, y: 18.0, r: 3.0),
        ],
        "git-pull-request": [
            .circle(x: 18.0, y: 18.0, r: 3.0),
            .circle(x: 6.0, y: 6.0, r: 3.0),
            .path("M13 6h3a2 2 0 0 1 2 2v7"),
            .line(x1: 6.0, y1: 9.0, x2: 6.0, y2: 21.0),
        ],
        "globe": [
            .circle(x: 12.0, y: 12.0, r: 10.0),
            .path("M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"),
            .path("M2 12h20"),
        ],
        "grip-vertical": [
            .circle(x: 9.0, y: 12.0, r: 1.0),
            .circle(x: 9.0, y: 5.0, r: 1.0),
            .circle(x: 9.0, y: 19.0, r: 1.0),
            .circle(x: 15.0, y: 12.0, r: 1.0),
            .circle(x: 15.0, y: 5.0, r: 1.0),
            .circle(x: 15.0, y: 19.0, r: 1.0),
        ],
        "heart": [
            .path("M2 9.5a5.5 5.5 0 0 1 9.591-3.676.56.56 0 0 0 .818 0A5.49 5.49 0 0 1 22 9.5c0 2.29-1.5 4-3 5.5l-5.492 5.313a2 2 0 0 1-3 .019L5 15c-1.5-1.5-3-3.2-3-5.5"),
        ],
        "house": [
            .path("M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"),
            .path("M3 10a2 2 0 0 1 .709-1.528l7-6a2 2 0 0 1 2.582 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"),
        ],
        "image": [
            .rect(x: 3.0, y: 3.0, width: 18.0, height: 18.0, rx: 2.0, ry: 2.0),
            .circle(x: 9.0, y: 9.0, r: 2.0),
            .path("m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"),
        ],
        "info": [
            .circle(x: 12.0, y: 12.0, r: 10.0),
            .path("M12 16v-4"),
            .path("M12 8h.01"),
        ],
        "layout-grid": [
            .rect(x: 3.0, y: 3.0, width: 7.0, height: 7.0, rx: 1.0, ry: 1.0),
            .rect(x: 14.0, y: 3.0, width: 7.0, height: 7.0, rx: 1.0, ry: 1.0),
            .rect(x: 14.0, y: 14.0, width: 7.0, height: 7.0, rx: 1.0, ry: 1.0),
            .rect(x: 3.0, y: 14.0, width: 7.0, height: 7.0, rx: 1.0, ry: 1.0),
        ],
        "list": [
            .path("M3 5h.01"),
            .path("M3 12h.01"),
            .path("M3 19h.01"),
            .path("M8 5h13"),
            .path("M8 12h13"),
            .path("M8 19h13"),
        ],
        "loader-circle": [
            .path("M21 12a9 9 0 1 1-6.219-8.56"),
        ],
        "lock": [
            .rect(x: 3.0, y: 11.0, width: 18.0, height: 11.0, rx: 2.0, ry: 2.0),
            .path("M7 11V7a5 5 0 0 1 10 0v4"),
        ],
        "log-out": [
            .path("m16 17 5-5-5-5"),
            .path("M21 12H9"),
            .path("M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"),
        ],
        "mail": [
            .path("m22 7-8.991 5.727a2 2 0 0 1-2.009 0L2 7"),
            .rect(x: 2.0, y: 4.0, width: 20.0, height: 16.0, rx: 2.0, ry: 2.0),
        ],
        "minus": [
            .path("M5 12h14"),
        ],
        "panel-left": [
            .rect(x: 3.0, y: 3.0, width: 18.0, height: 18.0, rx: 2.0, ry: 2.0),
            .path("M9 3v18"),
        ],
        "panel-right": [
            .rect(x: 3.0, y: 3.0, width: 18.0, height: 18.0, rx: 2.0, ry: 2.0),
            .path("M15 3v18"),
        ],
        "pause": [
            .rect(x: 14.0, y: 3.0, width: 5.0, height: 18.0, rx: 1.0, ry: 1.0),
            .rect(x: 5.0, y: 3.0, width: 5.0, height: 18.0, rx: 1.0, ry: 1.0),
        ],
        "pencil": [
            .path("M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"),
            .path("m15 5 4 4"),
        ],
        "play": [
            .path("M5 5a2 2 0 0 1 3.008-1.728l11.997 6.998a2 2 0 0 1 .003 3.458l-12 7A2 2 0 0 1 5 19z"),
        ],
        "plus": [
            .path("M5 12h14"),
            .path("M12 5v14"),
        ],
        "refresh-cw": [
            .path("M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"),
            .path("M21 3v5h-5"),
            .path("M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"),
            .path("M8 16H3v5"),
        ],
        "search": [
            .path("m21 21-4.34-4.34"),
            .circle(x: 11.0, y: 11.0, r: 8.0),
        ],
        "send": [
            .path("M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z"),
            .path("m21.854 2.147-10.94 10.939"),
        ],
        "settings": [
            .path("M9.671 4.136a2.34 2.34 0 0 1 4.659 0 2.34 2.34 0 0 0 3.319 1.915 2.34 2.34 0 0 1 2.33 4.033 2.34 2.34 0 0 0 0 3.831 2.34 2.34 0 0 1-2.33 4.033 2.34 2.34 0 0 0-3.319 1.915 2.34 2.34 0 0 1-4.659 0 2.34 2.34 0 0 0-3.32-1.915 2.34 2.34 0 0 1-2.33-4.033 2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915"),
            .circle(x: 12.0, y: 12.0, r: 3.0),
        ],
        "share": [
            .path("M12 2v13"),
            .path("m16 6-4-4-4 4"),
            .path("M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"),
        ],
        "slash": [
            .path("M22 2 2 22"),
        ],
        "sparkles": [
            .path("M11.017 2.814a1 1 0 0 1 1.966 0l1.051 5.558a2 2 0 0 0 1.594 1.594l5.558 1.051a1 1 0 0 1 0 1.966l-5.558 1.051a2 2 0 0 0-1.594 1.594l-1.051 5.558a1 1 0 0 1-1.966 0l-1.051-5.558a2 2 0 0 0-1.594-1.594l-5.558-1.051a1 1 0 0 1 0-1.966l5.558-1.051a2 2 0 0 0 1.594-1.594z"),
            .path("M20 2v4"),
            .path("M22 4h-4"),
            .circle(x: 4.0, y: 20.0, r: 2.0),
        ],
        "star": [
            .path("M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z"),
        ],
        "tag": [
            .path("M12.586 2.586A2 2 0 0 0 11.172 2H4a2 2 0 0 0-2 2v7.172a2 2 0 0 0 .586 1.414l8.704 8.704a2.426 2.426 0 0 0 3.42 0l6.58-6.58a2.426 2.426 0 0 0 0-3.42z"),
            .circle(x: 7.5, y: 7.5, r: 0.5),
        ],
        "terminal": [
            .path("M12 19h8"),
            .path("m4 17 6-6-6-6"),
        ],
        "trash-2": [
            .path("M10 11v6"),
            .path("M14 11v6"),
            .path("M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"),
            .path("M3 6h18"),
            .path("M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"),
        ],
        "triangle-alert": [
            .path("m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"),
            .path("M12 9v4"),
            .path("M12 17h.01"),
        ],
        "upload": [
            .path("M12 3v12"),
            .path("m17 8-5-5-5 5"),
            .path("M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"),
        ],
        "user": [
            .path("M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"),
            .circle(x: 12.0, y: 7.0, r: 4.0),
        ],
        "users": [
            .path("M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"),
            .path("M16 3.128a4 4 0 0 1 0 7.744"),
            .path("M22 21v-2a4 4 0 0 0-3-3.87"),
            .circle(x: 9.0, y: 7.0, r: 4.0),
        ],
        "x": [
            .path("M18 6 6 18"),
            .path("m6 6 12 12"),
        ],
        "zap": [
            .path("M15.914 4a1.5 1.5 0 00-2.474-1.561l-9 9A1.5 1.5 0 005.5 14h4.002a.5.5 0 01.471.666L8.086 20a1.5 1.5 0 002.475 1.56l9-9A1.5 1.5 0 0018.5 10h-3.997a.5.5 0 01-.472-.667z"),
        ],
    ]
}
