//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Reza Enayati on 9/30/24.
//
import SwiftData
import SwiftUI

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
