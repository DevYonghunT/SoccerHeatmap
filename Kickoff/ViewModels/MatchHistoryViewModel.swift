import Foundation
import Combine

class MatchHistoryViewModel: ObservableObject {
    @Published var matches: [MatchData] = []
    @Published var groupedMatches: [(String, [MatchData])] = []

    private let storageService: MatchStorageService
    private var cancellables = Set<AnyCancellable>()

    init(storageService: MatchStorageService) {
        self.storageService = storageService

        storageService.$matches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matches in
                self?.matches = matches
                self?.groupMatches(matches)
            }
            .store(in: &cancellables)

        matches = storageService.matches
        groupMatches(matches)
    }

    private func groupMatches(_ matches: [MatchData]) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"

        let grouped = Dictionary(grouping: matches) { formatter.string(from: $0.date) }
        groupedMatches = grouped.sorted { $0.key > $1.key }
    }

    func deleteMatch(_ match: MatchData) {
        storageService.deleteMatch(id: match.id)
    }

    // MARK: - Total Stats
    var totalMatches: Int { storageService.totalMatches }
    var totalWins: Int { storageService.totalWins }
    var totalDistance: Double { storageService.totalDistance }
    var winRate: Double { storageService.winRate }
}
