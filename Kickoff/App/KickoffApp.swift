import SwiftUI

@main
struct KickoffApp: App {
    @StateObject private var storageService = MatchStorageService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storageService)
                .preferredColorScheme(.dark)
        }
    }
}
