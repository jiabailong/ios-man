//
//  manyouApp.swift
//  manyou
//
//  Created by jiabailong1 on 2024/6/3.
//

import SwiftUI

@main
struct manyouApp: App {
    @StateObject private var userManager = UserManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
        }
    }
}
