import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var lastMatch: MatchData?
    @Published var weeklyStats: WeeklyStats = .empty
    @Published var recentMatches: [MatchData] = []

    private let storageService: MatchStorageService
    private var cancellables = Set<AnyCancellable>()

    init(storageService: MatchStorageService) {
        self.storageService = storageService

        storageService.$matches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)

        refresh()
    }

    func refresh() {
        lastMatch = storageService.lastMatch
        weeklyStats = storageService.weeklyStats()
        recentMatches = storageService.recentMatches(limit: 5)
    }
}
