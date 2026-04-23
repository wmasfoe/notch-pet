//
//  PetView.swift
//  NotchPet
//

import SwiftUI

struct PetView: View {
    @ObservedObject var viewModel: NotchViewModel

    @State private var appearedAt = Date()
    @State private var lastInteractionAt = Date()
    @State private var isPointerInside = false
    @State private var wakePulse = false

    private let closedAnimation = Animation.spring(response: 0.34, dampingFraction: 0.9)
    private let openedAnimation = Animation.spring(response: 0.42, dampingFraction: 0.82)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
            let size = viewModel.currentSize
            let sleeping = isSleeping(at: timeline.date)

            ZStack(alignment: .top) {
                Color.clear

                VStack(spacing: 0) {
                    panelBody(date: timeline.date, sleeping: sleeping)
                        .frame(width: size.width, height: size.height, alignment: .top)
                        .background(panelBackground)
                        .clipShape(
                            NotchShape(
                                topCornerRadius: topCornerRadius,
                                bottomCornerRadius: bottomCornerRadius
                            )
                        )
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: 1)
                                .padding(.horizontal, topCornerRadius)
                        }
                        .shadow(
                            color: .black.opacity(viewModel.status == .closed ? 0.28 : 0.52),
                            radius: viewModel.status == .expanded ? 18 : 10,
                            y: 6
                        )
                        .scaleEffect(wakePulse ? 1.018 : 1, anchor: .top)
                        .contentShape(Rectangle())
                        .onHover { hovering in
                            isPointerInside = hovering
                            if hovering {
                                markInteraction()
                            }
                            viewModel.handleHover(hovering)
                        }
                        .onTapGesture {
                            markInteraction()
                            viewModel.toggleExpanded()
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .onAppear {
            let now = Date()
            appearedAt = now
            lastInteractionAt = now
        }
        .preferredColorScheme(.dark)
        .animation(viewModel.status == .expanded ? openedAnimation : closedAnimation, value: viewModel.status)
    }

    @ViewBuilder
    private func panelBody(date: Date, sleeping: Bool) -> some View {
        VStack(alignment: .leading, spacing: viewModel.status == .expanded ? 10 : 0) {
            if viewModel.status == .expanded {
                HStack(spacing: 8) {
                    Capsule()
                        .fill(sleeping ? Color(red: 0.44, green: 0.58, blue: 0.9) : Color(red: 0.97, green: 0.55, blue: 0.22))
                        .frame(width: 8, height: 8)

                    Text(sleeping ? "Nap Mode" : "Patrol Mode")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))

                    Spacer()

                    Text("Click to fold")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            petStage(date: date, sleeping: sleeping)
                .frame(
                    height: viewModel.status == .expanded ? 88 : (viewModel.status == .hovered ? 48 : 40)
                )
                .padding(.horizontal, viewModel.status == .expanded ? 14 : 10)
                .padding(.top, viewModel.status == .expanded ? 0 : 4)

            if viewModel.status == .expanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(sleeping ? "休息时会蜷在刘海下方，悬停后会立刻醒来。" : "沿着刘海底边巡逻，进入悬停态后会弹性展开。")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        statChip(title: "Blend", value: "Notch")
                        statChip(title: "State", value: sleeping ? "Sleep" : "Walk")
                        statChip(title: "Feel", value: "Spring")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
    }

    private func petStage(date: Date, sleeping: Bool) -> some View {
        GeometryReader { proxy in
            let spriteScale = catScale
            let spriteWidth = 16 * spriteScale
            let progress = movementProgress(at: date, sleeping: sleeping)
            let availableWidth = max(proxy.size.width - spriteWidth - 10, 0)
            let x = sleeping ? proxy.size.width * 0.54 : 5 + availableWidth * progress
            let directionRight = walkingDirection(at: date)
            let bodyLift = sleeping ? 0 : walkingBounce(at: date)

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(viewModel.status == .expanded ? 0.08 : 0.04),
                                Color.white.opacity(0.01)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 1)
                    }
                    .padding(.bottom, viewModel.status == .expanded ? 14 : 8)

                Ellipse()
                    .fill(Color.black.opacity(0.28))
                    .frame(
                        width: sleeping ? spriteWidth * 0.9 : spriteWidth * 0.72,
                        height: sleeping ? 8 : 6
                    )
                    .offset(
                        x: sleeping ? x - spriteWidth * 0.2 : x + spriteWidth * 0.12,
                        y: viewModel.status == .expanded ? -10 : -5
                    )

                CatPixelArt(
                    isSleeping: sleeping,
                    frame: frameIndex(at: date, sleeping: sleeping),
                    scale: spriteScale,
                    mirrored: sleeping ? false : directionRight
                )
                .offset(
                    x: sleeping ? x - spriteWidth * 0.18 : x,
                    y: sleeping ? 0 : -bodyLift
                )

                if sleeping {
                    SleepBubbleStack(tick: date.timeIntervalSince(appearedAt))
                        .offset(x: x + spriteWidth * 0.6, y: -32)
                }
            }
        }
    }

    private func statChip(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title.uppercased())
                .foregroundStyle(.white.opacity(0.4))
            Text(value)
                .foregroundStyle(.white.opacity(0.9))
        }
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.06), in: Capsule())
    }

    private var panelBackground: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [
                    Color.white.opacity(viewModel.status == .expanded ? 0.09 : 0.05),
                    Color.clear,
                    Color.black.opacity(0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var topCornerRadius: CGFloat {
        switch viewModel.status {
        case .closed:
            return 6
        case .hovered:
            return 10
        case .expanded:
            return 18
        }
    }

    private var bottomCornerRadius: CGFloat {
        switch viewModel.status {
        case .closed:
            return 14
        case .hovered:
            return 18
        case .expanded:
            return 26
        }
    }

    private var catScale: CGFloat {
        switch viewModel.status {
        case .closed:
            return 2.0
        case .hovered:
            return 2.3
        case .expanded:
            return 3.1
        }
    }

    private func isSleeping(at date: Date) -> Bool {
        guard viewModel.status == .closed else { return false }
        guard !isPointerInside else { return false }
        return date.timeIntervalSince(lastInteractionAt) > 4.2
    }

    private func frameIndex(at date: Date, sleeping: Bool) -> Int {
        let elapsed = date.timeIntervalSince(appearedAt)
        if sleeping {
            return Int(elapsed * 1.6) % 2
        }
        return Int(elapsed * 10) % 4
    }

    private func movementProgress(at date: Date, sleeping: Bool) -> CGFloat {
        guard !sleeping else { return 0.56 }

        let duration: TimeInterval
        switch viewModel.status {
        case .closed:
            duration = 2.9
        case .hovered:
            duration = 3.6
        case .expanded:
            duration = 4.8
        }

        let total = duration * 2
        let elapsed = date.timeIntervalSince(appearedAt).truncatingRemainder(dividingBy: total)
        let phase = elapsed / duration
        let progress = phase <= 1 ? phase : (2 - phase)
        return min(max(progress, 0), 1)
    }

    private func walkingDirection(at date: Date) -> Bool {
        let duration: TimeInterval
        switch viewModel.status {
        case .closed:
            duration = 2.9
        case .hovered:
            duration = 3.6
        case .expanded:
            duration = 4.8
        }
        let elapsed = date.timeIntervalSince(appearedAt).truncatingRemainder(dividingBy: duration * 2)
        return elapsed < duration
    }

    private func walkingBounce(at date: Date) -> CGFloat {
        let elapsed = date.timeIntervalSince(appearedAt)
        return abs(sin(elapsed * 10)) * (viewModel.status == .expanded ? 4 : 2.4)
    }

    private func markInteraction() {
        let now = Date()
        lastInteractionAt = now
        wakePulse = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            wakePulse = false
        }
    }
}

private struct SleepBubbleStack: View {
    let tick: TimeInterval

    var body: some View {
        VStack(alignment: .leading, spacing: -4) {
            bubble(size: 14, phase: tick * 1.1)
            bubble(size: 10, phase: tick * 1.1 + 0.6)
            bubble(size: 7, phase: tick * 1.1 + 1.0)
        }
    }

    private func bubble(size: CGFloat, phase: TimeInterval) -> some View {
        Text("z")
            .font(.system(size: size, weight: .black, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.58))
            .offset(y: -CGFloat(sin(phase)) * 3)
            .opacity(0.48 + abs(cos(phase)) * 0.28)
    }
}
