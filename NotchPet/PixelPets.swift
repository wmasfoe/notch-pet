//
//  PixelPets.swift
//  NotchPet
//

import SwiftUI

private let catPalette: [Character: Color] = [
    "G": Color(red: 0.96, green: 0.58, blue: 0.22),
    "D": Color(red: 0.56, green: 0.29, blue: 0.13),
    "C": Color(red: 1.0, green: 0.84, blue: 0.62),
    "P": Color(red: 0.97, green: 0.63, blue: 0.65)
]

private let walkingFrames: [[String]] = [
    [
        "................",
        ".............G..",
        "............GG..",
        ".....GG....GG...",
        "...GGGGGGGGGGG..",
        "..GGCGGGGGCGGGG.",
        "..GGGGGGGGGGGG..",
        "...GDGGPGGGGG...",
        "....GGGGGGGG....",
        "...G..G...G.....",
        "..G..G...G......",
        "................"
    ],
    [
        "................",
        ".............G..",
        "............GG..",
        ".....GG....GG...",
        "...GGGGGGGGGGG..",
        "..GGCGGGGGCGGGG.",
        "..GGGGGGGGGGGG..",
        "...GDGGPGGGGG...",
        "....GGGGGGGG....",
        ".....G...G......",
        "...G..G...G.....",
        "................"
    ],
    [
        "................",
        ".............G..",
        "............GG..",
        ".....GG....GG...",
        "...GGGGGGGGGGG..",
        "..GGCGGGGGCGGGG.",
        "..GGGGGGGGGGGG..",
        "...GDGGPGGGGG...",
        "....GGGGGGGG....",
        "...G...G..G.....",
        "..G...G..G......",
        "................"
    ],
    [
        "................",
        ".............G..",
        "............GG..",
        ".....GG....GG...",
        "...GGGGGGGGGGG..",
        "..GGCGGGGGCGGGG.",
        "..GGGGGGGGGGGG..",
        "...GDGGPGGGGG...",
        "....GGGGGGGG....",
        "....G...G.......",
        "..G...G..G......",
        "................"
    ]
]

private let sleepingFrames: [[String]] = [
    [
        "................",
        "................",
        ".....GGGGGG.....",
        "....GGGGGGGG....",
        "...GGCGGGCGGG...",
        "...GGGGGGGGGG...",
        "....GDGPPGDG....",
        ".....GGGGGG.....",
        "....GG....GG....",
        "...GG......GG...",
        "................",
        "................"
    ],
    [
        "................",
        "................",
        ".....GGGGGG.....",
        "....GGGGGGGG....",
        "...GGCGGGCGGG...",
        "...GGGGGGGGGG...",
        "....GDGPPGDG....",
        ".....GGGGGG.....",
        ".....GG..GG.....",
        "...GG......GG...",
        "................",
        "................"
    ]
]

struct PixelSpriteView: View {
    let rows: [String]
    let pixelSize: CGFloat
    var mirrored: Bool = false

    var body: some View {
        let width = CGFloat(rows.first?.count ?? 0) * pixelSize
        let height = CGFloat(rows.count) * pixelSize

        Canvas { context, _ in
            for (y, row) in rows.enumerated() {
                for (x, token) in row.enumerated() {
                    guard let color = catPalette[token] else { continue }
                    let rect = CGRect(
                        x: CGFloat(x) * pixelSize,
                        y: CGFloat(y) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: width, height: height)
        .scaleEffect(x: mirrored ? -1 : 1, y: 1, anchor: .center)
    }
}

struct CatPixelArt: View {
    let isSleeping: Bool
    let frame: Int
    let scale: CGFloat
    let mirrored: Bool

    var body: some View {
        PixelSpriteView(
            rows: currentFrame,
            pixelSize: scale,
            mirrored: mirrored
        )
    }

    private var currentFrame: [String] {
        if isSleeping {
            return sleepingFrames[frame % sleepingFrames.count]
        }
        return walkingFrames[frame % walkingFrames.count]
    }
}
