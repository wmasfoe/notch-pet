//
//  NotchPetApp.swift
//  NotchPet
//
//  像素风宠物显示在 Mac 刘海上
//

import SwiftUI

@main
struct NotchPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
