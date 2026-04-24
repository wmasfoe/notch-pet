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

    private let transitionAnimation = Animation.spring(response: 0.36, dampingFraction: 0.84)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
            let chromeSize = viewModel.visibleChromeSize
            let sleeping = isSleeping(at: timeline.date)

            ZStack(alignment: .top) {
                Color.clear

                chromeBody(date: timeline.date, sleeping: sleeping)
                    .frame(
                        width: chromeSize.width,
                        height: chromeSize.height,
                        alignment: .top
                    )
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        isPointerInside = hovering
                        if hovering {
                            lastInteractionAt = .now
                        }
                        viewModel.handleHover(hovering)
                    }
                    .onTapGesture {
                        lastInteractionAt = .now
                        if !viewModel.isExpanded {
                            viewModel.toggleExpanded()
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            let now = Date()
            appearedAt = now
            lastInteractionAt = now
        }
        .preferredColorScheme(.dark)
        .animation(transitionAnimation, value: viewModel.status)
        .animation(transitionAnimation, value: viewModel.baseMode)
        .animation(.easeInOut(duration: 0.18), value: isPointerInside)
    }

    @ViewBuilder
    private func chromeBody(date: Date, sleeping: Bool) -> some View {
        switch viewModel.status {
        case .idle:
            idleChrome(date: date, sleeping: sleeping)
        case .active:
            activeChrome(date: date, sleeping: false)
        case .expanded:
            expandedChrome(date: date, sleeping: false)
        }
    }

    private func idleChrome(date: Date, sleeping: Bool) -> some View {
        let chromeSize = viewModel.visibleChromeSize
        let spriteScale = catScale
        let spriteWidth = 16 * spriteScale
        let centeredX = (chromeSize.width - spriteWidth) / 2

        return ZStack(alignment: .topLeading) {
            NotchShape(topCornerRadius: 6, bottomCornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.94),
                            Color.black.opacity(0.82)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: chromeSize.width, height: 12)

            Capsule()
                .fill(Color.white.opacity(0.08))
                .frame(width: chromeSize.width - 22, height: 1)
                .offset(x: 11, y: 10)

            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: spriteWidth * 0.8, height: 5)
                .offset(x: centeredX + spriteWidth * 0.1, y: 27)

            CatPixelArt(
                isSleeping: sleeping,
                frame: frameIndex(at: date, sleeping: sleeping),
                scale: spriteScale,
                mirrored: false
            )
            .offset(x: centeredX, y: 4)

            if sleeping {
                SleepBubbleStack(tick: date.timeIntervalSince(appearedAt))
                    .offset(x: centeredX + spriteWidth * 0.7, y: -10)
            }
        }
    }

    private func activeChrome(date: Date, sleeping: Bool) -> some View {
        let chromeSize = viewModel.visibleChromeSize

        return islandChrome(
            size: chromeSize,
            topRadius: 10,
            bottomRadius: 20
        ) {
            patrolStage(
                date: date,
                sleeping: sleeping,
                stageHeight: chromeSize.height
            )
            .padding(.horizontal, 10)
            .padding(.top, 4)
        }
    }

    private func expandedChrome(date: Date, sleeping: Bool) -> some View {
        let chromeSize = viewModel.visibleChromeSize

        return islandChrome(
            size: chromeSize,
            topRadius: 18,
            bottomRadius: 26
        ) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(viewModel.baseMode == .active ? Color.orange : Color.blue)
                        .frame(width: 8, height: 8)

                    Text("Notch Pet")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))

                    Spacer()

                    Button {
                        viewModel.closeExpanded()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.55))
                            .frame(width: 20, height: 20)
                            .background(Color.white.opacity(0.08), in: Circle())
                    }
                    .buttonStyle(.plain)
                }

                patrolStage(
                    date: date,
                    sleeping: sleeping,
                    stageHeight: 82
                )
                .frame(height: 82)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mode")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))

                    Picker("Mode", selection: baseModeBinding) {
                        ForEach(NotchBaseMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Hover can wake the pet into active mode, but only a click opens this panel.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 6) {
                    statChip(title: "Hover", value: "Active")
                    statChip(title: "Expand", value: "Click")
                    statChip(title: "Info", value: "Manual")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 14)
        }
    }

    private func islandChrome<Content: View>(
        size: CGSize,
        topRadius: CGFloat,
        bottomRadius: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .top) {
            NotchShape(topCornerRadius: topRadius, bottomCornerRadius: bottomRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black,
                            Color.black.opacity(0.96),
                            Color.black.opacity(0.88)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
                .padding(.horizontal, topRadius + 2)

            content()
        }
        .frame(width: size.width, height: size.height, alignment: .top)
        .shadow(color: .black.opacity(0.42), radius: 14, y: 6)
    }

    private func patrolStage(date: Date, sleeping: Bool, stageHeight: CGFloat) -> some View {
        GeometryReader { proxy in
            let spriteScale = catScale
            let spriteWidth = 16 * spriteScale
            let progress = movementProgress(at: date, sleeping: sleeping)
            let availableWidth = max(proxy.size.width - spriteWidth - 12, 0)
            let x = sleeping ? proxy.size.width * 0.55 : 6 + availableWidth * progress
            let directionRight = walkingDirection(at: date)
            let bodyLift = sleeping ? 0 : walkingBounce(at: date)

            ZStack(alignment: .bottomLeading) {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: max(proxy.size.width - 8, 40), height: 1)
                    .offset(x: 4, y: stageHeight - 18)

                Ellipse()
                    .fill(Color.black.opacity(0.26))
                    .frame(width: sleeping ? spriteWidth * 0.9 : spriteWidth * 0.72, height: 6)
                    .offset(
                        x: sleeping ? x - spriteWidth * 0.2 : x + spriteWidth * 0.14,
                        y: stageHeight - 19
                    )

                CatPixelArt(
                    isSleeping: sleeping,
                    frame: frameIndex(at: date, sleeping: sleeping),
                    scale: spriteScale,
                    mirrored: sleeping ? false : directionRight
                )
                .offset(x: sleeping ? x - spriteWidth * 0.18 : x, y: stageHeight - (sleeping ? 29 : 34 + bodyLift))
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

    private var baseModeBinding: Binding<NotchBaseMode> {
        Binding(
            get: { viewModel.baseMode },
            set: { viewModel.setManualMode($0) }
        )
    }

    private var catScale: CGFloat {
        switch viewModel.status {
        case .idle:
            return 2.0
        case .active:
            return 2.4
        case .expanded:
            return 2.9
        }
    }

    private func isSleeping(at date: Date) -> Bool {
        guard viewModel.status == .idle else { return false }
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
        case .idle:
            duration = 3.2
        case .active:
            duration = 3.8
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
        case .idle:
            duration = 3.2
        case .active:
            duration = 3.8
        case .expanded:
            duration = 4.8
        }
        let elapsed = date.timeIntervalSince(appearedAt).truncatingRemainder(dividingBy: duration * 2)
        return elapsed < duration
    }

    private func walkingBounce(at date: Date) -> CGFloat {
        let elapsed = date.timeIntervalSince(appearedAt)
        return abs(sin(elapsed * 10)) * (viewModel.status == .expanded ? 4.2 : 2.8)
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
