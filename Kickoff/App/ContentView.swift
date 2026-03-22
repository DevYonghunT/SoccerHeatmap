import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storageService: MatchStorageService

    var body: some View {
        DashboardView(storageService: storageService)
            .environmentObject(storageService)
    }
}
