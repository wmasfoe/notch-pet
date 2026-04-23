//
//  NSScreen+Notch.swift
//  NotchPet
//

import AppKit

extension NSScreen {
    /// 检测屏幕是否有物理刘海
    var hasPhysicalNotch: Bool {
        guard let auxiliaryTopLeftArea = auxiliaryTopLeftArea,
              let auxiliaryTopRightArea = auxiliaryTopRightArea else {
            return false
        }
        return auxiliaryTopLeftArea.height > 0 && auxiliaryTopRightArea.height > 0
    }
    
    /// 获取刘海尺寸
    var notchSize: CGSize {
        if hasPhysicalNotch,
           let topLeft = auxiliaryTopLeftArea,
           let topRight = auxiliaryTopRightArea {
            let notchWidth = frame.width - topLeft.width - topRight.width
            let notchHeight = max(topLeft.height, topRight.height)
            return CGSize(width: notchWidth, height: notchHeight)
        }
        // 没有刘海的设备，返回默认尺寸
        return CGSize(width: 200, height: 30)
    }
}
