"""Converts Lucide SVGs into the Swift table ShadLucideShape draws from.

Reads every .svg in $SVG_DIR and writes the generated source to stdout.
"""
import os
import pathlib
import re

src = pathlib.Path(os.environ["SVG_DIR"])
out = ['''// Generated from the Lucide icon set (https://lucide.dev), ISC licensed.
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
''']


def num(value):
    return repr(float(value))


for svg in sorted(src.glob("*.svg")):
    text = svg.read_text()
    body = text[text.index(">", text.index("<svg")) + 1:]
    commands = []
    for tag in re.finditer(r"<(path|circle|rect|line)\b([^>]*?)/>", body):
        kind, attrs = tag.group(1), tag.group(2)

        def attr(key, default=None):
            found = re.search(rf'\b{key}="([^"]*)"', attrs)
            return found.group(1) if found else default

        if kind == "path":
            commands.append(f'.path("{attr("d")}")')
        elif kind == "circle":
            commands.append(
                f'.circle(x: {num(attr("cx"))}, y: {num(attr("cy"))}, r: {num(attr("r"))})'
            )
        elif kind == "rect":
            rx = attr("rx", "0")
            ry = attr("ry", rx)
            commands.append(
                f'.rect(x: {num(attr("x", "0"))}, y: {num(attr("y", "0"))}, '
                f'width: {num(attr("width"))}, height: {num(attr("height"))}, '
                f'rx: {num(rx)}, ry: {num(ry)})'
            )
        elif kind == "line":
            commands.append(
                f'.line(x1: {num(attr("x1"))}, y1: {num(attr("y1"))}, '
                f'x2: {num(attr("x2"))}, y2: {num(attr("y2"))})'
            )

    joined = ",\n            ".join(commands)
    out.append(f'        "{svg.stem}": [\n            {joined},\n        ],\n')

out.append("    ]\n}\n")
print("".join(out), end="")
