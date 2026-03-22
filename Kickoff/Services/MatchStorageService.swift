import Foundation

class MatchStorageService: ObservableObject {
    @Published var matches: [MatchData] = []

    private let fileManager = FileManager.default

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var matchesFileURL: URL {
        documentsURL.appendingPathComponent("kickoff_matches.json")
    }

    init() {
        loadMatches()
    }

    // MARK: - CRUD

    func saveMatch(_ match: MatchData) {
        // 중복 방지
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index] = match
        } else {
            matches.insert(match, at: 0)
        }
        persistMatches()
    }

    func deleteMatch(id: String) {
        matches.removeAll { $0.id == id }
        persistMatches()
    }

    func getMatch(id: String) -> MatchData? {
        matches.first { $0.id == id }
    }

    // MARK: - Persistence

    private func loadMatches() {
        guard fileManager.fileExists(atPath: matchesFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: matchesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            matches = try decoder.decode([MatchData].self, from: data)
        } catch {
            print("경기 데이터 로드 실패: \(error.localizedDescription)")
        }
    }

    private func persistMatches() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(matches)
            try data.write(to: matchesFileURL, options: .atomicWrite)
        } catch {
            print("경기 데이터 저장 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Stats

    var lastMatch: MatchData? {
        matches.first
    }

    func weeklyStats() -> WeeklyStats {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekMatches = matches.filter { $0.date >= startOfWeek }

        return WeeklyStats(
            totalCalories: weekMatches.reduce(0) { $0 + $1.stats.caloriesBurned },
            totalDistanceKm: weekMatches.reduce(0) { $0 + $1.stats.totalDistanceKm },
            matchCount: weekMatches.count,
            totalSprints: weekMatches.reduce(0) { $0 + $1.stats.sprintCount },
            maxSpeedKmh: weekMatches.map(\.stats.maxSpeedKmh).max() ?? 0
        )
    }

    func recentMatches(limit: Int = 5) -> [MatchData] {
        Array(matches.prefix(limit))
    }

    func matchesByMonth() -> [String: [MatchData]] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return Dictionary(grouping: matches) { formatter.string(from: $0.date) }
    }

    // MARK: - Totals

    var totalMatches: Int { matches.count }

    var totalWins: Int { matches.filter { $0.result == .win }.count }

    var totalDistance: Double { matches.reduce(0) { $0 + $1.stats.totalDistanceKm } }

    var winRate: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(totalWins) / Double(totalMatches) * 100
    }
}
