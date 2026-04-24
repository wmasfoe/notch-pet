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
    @State private var contentIsRevealed = true
    @State private var idleRestSide = IdleRestSide.random()

    private let islandAnimation = Animation.interpolatingSpring(
        mass: 0.72,
        stiffness: 430,
        damping: 31,
        initialVelocity: 0.9
    )
    private let contentAnimation = Animation.easeOut(duration: 0.18)

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
        .animation(islandAnimation, value: viewModel.status)
        .animation(islandAnimation, value: viewModel.baseMode)
        .animation(.easeInOut(duration: 0.18), value: isPointerInside)
        .onChange(of: viewModel.status) { _ in
            lastInteractionAt = .now
            contentIsRevealed = false
            if viewModel.status == .idle {
                idleRestSide = .random()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                contentIsRevealed = true
            }
        }
    }

    @ViewBuilder
    private func chromeBody(date: Date, sleeping: Bool) -> some View {
        let metrics = chromeMetrics

        switch viewModel.status {
        case .idle:
            idleChrome(date: date)
        case .active, .expanded:
            islandChrome(
                size: viewModel.visibleChromeSize,
                topRadius: metrics.topRadius,
                bottomRadius: metrics.bottomRadius,
                shadowOpacity: metrics.shadowOpacity
            ) {
                statusContent(date: date, sleeping: sleeping)
                    .opacity(contentIsRevealed ? 1 : 0)
                    .offset(y: contentIsRevealed ? 0 : -8)
                    .animation(contentAnimation, value: contentIsRevealed)
            }
        }
    }

    @ViewBuilder
    private func statusContent(date: Date, sleeping: Bool) -> some View {
        switch viewModel.status {
        case .idle:
            idleContent(date: date)
        case .active:
            activeContent(date: date, sleeping: false)
        case .expanded:
            expandedContent(date: date, sleeping: false)
        }
    }

    private func idleChrome(date: Date) -> some View {
        let chromeSize = viewModel.visibleChromeSize
        let notchWidth = min(viewModel.deviceNotchRect.width, chromeSize.width)
        let wingWidth = max((chromeSize.width - notchWidth) / 2, 0)

        return ZStack(alignment: .top) {
            HStack(spacing: 0) {
                idleWing(roundsOuterLeftCorner: true)
                    .frame(width: wingWidth, height: chromeSize.height)

                Rectangle()
                    .fill(idleFill)
                    .frame(width: notchWidth, height: chromeSize.height)

                idleWing(roundsOuterLeftCorner: false)
                    .frame(width: wingWidth, height: chromeSize.height)
            }
            .frame(width: chromeSize.width, height: chromeSize.height)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 2)

            idleContent(date: date)
                .opacity(contentIsRevealed ? 1 : 0)
                .offset(y: contentIsRevealed ? 0 : -6)
                .animation(contentAnimation, value: contentIsRevealed)

            Capsule()
                .fill(Color.white.opacity(0.075))
                .frame(width: max(chromeSize.width - 34, 24), height: 1)
                .offset(y: max(chromeSize.height - 5, 0))
        }
        .frame(width: chromeSize.width, height: chromeSize.height, alignment: .top)
    }

    private func idleWing(roundsOuterLeftCorner: Bool) -> some View {
        IdleWingShape(roundsOuterLeftCorner: roundsOuterLeftCorner, radius: 13)
            .fill(idleFill)
    }

    private var idleFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.black.opacity(0.98),
                Color.black.opacity(0.92)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func idleContent(date: Date) -> some View {
        let chromeSize = viewModel.visibleChromeSize
        let spriteScale = catScale
        let spriteWidth = 16 * spriteScale
        let notchWidth = min(viewModel.deviceNotchRect.width, chromeSize.width)
        let wingWidth = max((chromeSize.width - notchWidth) / 2, spriteWidth + 12)
        let sideInset = max((wingWidth - spriteWidth) / 2, 8)
        let leftRestingX = sideInset
        let rightRestingX = chromeSize.width - wingWidth + sideInset
        let restingX = idleRestSide == .left ? leftRestingX : rightRestingX
        let bubbleOffset = idleRestSide == .left ? spriteWidth * 0.56 : spriteWidth * 0.72
        let tick = date.timeIntervalSince(appearedAt)

        return ZStack(alignment: .topLeading) {
            Ellipse()
                .fill(Color.black.opacity(0.18))
                .frame(width: spriteWidth * 0.86, height: 5)
                .offset(x: restingX + spriteWidth * 0.08, y: chromeSize.height - 6)

            CatPixelArt(
                isSleeping: true,
                frame: frameIndex(at: date, sleeping: true),
                scale: spriteScale,
                mirrored: false
            )
            .offset(x: restingX, y: max(0, chromeSize.height - 30) - CGFloat(sin(tick * 1.2)) * 0.8)

            SleepBubbleStack(tick: tick)
                .offset(x: restingX + bubbleOffset, y: -8)
        }
        .frame(width: chromeSize.width, height: chromeSize.height, alignment: .topLeading)
    }

    private func activeContent(date: Date, sleeping: Bool) -> some View {
        let chromeSize = viewModel.visibleChromeSize

        return ZStack(alignment: .top) {
            patrolStage(
                date: date,
                sleeping: sleeping,
                stageHeight: chromeSize.height
            )
            .padding(.horizontal, 10)
            .padding(.top, 4)
        }
    }

    private func expandedContent(date: Date, sleeping: Bool) -> some View {
        let chromeSize = viewModel.visibleChromeSize

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                Circle()
                    .fill(viewModel.baseMode == .active ? Color.orange : Color.cyan)
                    .frame(width: 8, height: 8)
                    .shadow(color: (viewModel.baseMode == .active ? Color.orange : Color.cyan).opacity(0.8), radius: 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.baseMode == .active ? "小猫巡逻中" : "小猫在休息")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))

                    Text("点击收起，悬停只唤醒，不自动展开")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer()

                Button {
                    viewModel.closeExpanded()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.58))
                        .frame(width: 22, height: 22)
                        .background(Color.white.opacity(0.09), in: Circle())
                }
                .buttonStyle(.plain)
            }

            patrolStage(
                date: date,
                sleeping: sleeping,
                stageHeight: 74
            )
            .frame(height: 74)
            .padding(.horizontal, -2)

            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("手动状态")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))

                    Picker("手动状态", selection: baseModeBinding) {
                        ForEach(NotchBaseMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: min(190, chromeSize.width * 0.52))
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        statChip(title: "悬停", value: "唤醒")
                        statChip(title: "展开", value: "点击")
                    }

                    Text("当前只做展示与状态切换")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.42))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 13)
    }

    private func islandChrome<Content: View>(
        size: CGSize,
        topRadius: CGFloat,
        bottomRadius: CGFloat,
        shadowOpacity: Double,
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
        .shadow(color: .black.opacity(shadowOpacity), radius: 14, y: 6)
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

    private var chromeMetrics: (topRadius: CGFloat, bottomRadius: CGFloat, shadowOpacity: Double) {
        switch viewModel.status {
        case .idle:
            return (8, 16, 0.22)
        case .active:
            return (10, 20, 0.42)
        case .expanded:
            return (18, 28, 0.5)
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

private enum IdleRestSide {
    case left
    case right

    static func random() -> IdleRestSide {
        Bool.random() ? .left : .right
    }
}

private struct IdleWingShape: Shape {
    var roundsOuterLeftCorner: Bool
    var radius: CGFloat

    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let resolvedRadius = min(radius, rect.width, rect.height)
        var path = Path()

        if roundsOuterLeftCorner {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + resolvedRadius, y: rect.maxY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - resolvedRadius),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - resolvedRadius))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - resolvedRadius, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }

        return path
    }
}
