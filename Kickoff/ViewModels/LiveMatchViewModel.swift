import Foundation
import Combine

enum LiveMatchStatus {
    case idle, running, paused, stopped
}

class LiveMatchViewModel: ObservableObject {
    // MARK: - Published State
    @Published var status: LiveMatchStatus = .idle
    @Published var elapsedSeconds: Int = 0
    @Published var currentHeartRate: Int = 0
    @Published var heartRateZone: HeartRateZone = .zone1
    @Published var totalDistanceKm: Double = 0
    @Published var maxSpeedKmh: Double = 0
    @Published var currentSpeedKmh: Double = 0
    @Published var caloriesBurned: Int = 0
    @Published var sprintCount: Int = 0
    @Published var sprintDistanceKm: Double = 0
    @Published var locationHistory: [LocationPoint] = []

    // MARK: - Services
    let healthService: HealthKitService
    let locationService: LocationService
    private let storageService: MatchStorageService

    // MARK: - Private
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var matchStartDate: Date?
    private var fieldSize: FieldSize?

    var isActive: Bool {
        status == .running || status == .paused
    }

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var halfLabel: String {
        if elapsedSeconds < 45 * 60 {
            return "전반전"
        } else {
            return "후반전"
        }
    }

    init(healthService: HealthKitService, locationService: LocationService, storageService: MatchStorageService) {
        self.healthService = healthService
        self.locationService = locationService
        self.storageService = storageService
        setupBindings()
    }

    private func setupBindings() {
        healthService.$currentHeartRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bpm in
                self?.currentHeartRate = bpm
                self?.heartRateZone = HeartRateZone.from(bpm: bpm)
            }
            .store(in: &cancellables)

        locationService.$currentSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                self?.currentSpeedKmh = speed
                if speed > (self?.maxSpeedKmh ?? 0) {
                    self?.maxSpeedKmh = speed
                }
            }
            .store(in: &cancellables)

        locationService.$totalDistance
            .receive(on: DispatchQueue.main)
            .map { $0 / 1000.0 }
            .assign(to: &$totalDistanceKm)

        locationService.$sprintCount
            .receive(on: DispatchQueue.main)
            .assign(to: &$sprintCount)

        locationService.$sprintDistance
            .receive(on: DispatchQueue.main)
            .map { $0 / 1000.0 }
            .assign(to: &$sprintDistanceKm)

        locationService.$locationHistory
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationHistory)
    }

    // MARK: - Match Control

    func startMatch(fieldSize: FieldSize? = nil) async {
        self.fieldSize = fieldSize
        matchStartDate = Date()

        _ = await healthService.requestAuthorization()
        healthService.startHeartRateMonitoring()
        await healthService.startWorkout()

        locationService.requestAuthorization()
        locationService.startTracking()

        await MainActor.run {
            status = .running
            startTimer()
        }
    }

    func pauseMatch() {
        status = .paused
        timer?.invalidate()
        timer = nil
        locationService.pauseTracking()
    }

    func resumeMatch() {
        status = .running
        startTimer()
        locationService.resumeTracking()
    }

    func stopMatch() async -> MatchData {
        status = .stopped
        timer?.invalidate()
        timer = nil

        locationService.stopTracking()
        healthService.stopHeartRateMonitoring()
        let calories = await healthService.endWorkout()

        let avgSpeed: Double = {
            let duration = Double(elapsedSeconds) / 3600.0
            guard duration > 0 else { return 0 }
            return totalDistanceKm / duration
        }()

        await MainActor.run {
            self.caloriesBurned = Int(calories)
        }

        let stats = MatchStats(
            totalDistanceKm: totalDistanceKm,
            averageHeartRate: healthService.averageHeartRate,
            maxHeartRate: healthService.maxHeartRate,
            maxSpeedKmh: maxSpeedKmh,
            averageSpeedKmh: avgSpeed,
            sprintCount: sprintCount,
            caloriesBurned: Int(calories),
            sprintDistanceKm: sprintDistanceKm
        )

        let match = MatchData(
            date: matchStartDate ?? Date(),
            durationMinutes: elapsedSeconds / 60,
            stats: stats,
            locationHistory: locationHistory,
            fieldSize: fieldSize
        )

        return match
    }

    func reset() {
        status = .idle
        elapsedSeconds = 0
        currentHeartRate = 0
        heartRateZone = .zone1
        totalDistanceKm = 0
        maxSpeedKmh = 0
        currentSpeedKmh = 0
        caloriesBurned = 0
        sprintCount = 0
        sprintDistanceKm = 0
        locationHistory = []
        healthService.reset()
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.elapsedSeconds += 1
            }
        }
    }
}
