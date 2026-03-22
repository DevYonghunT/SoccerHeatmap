import Foundation
import HealthKit
import Combine

enum HeartRateZone: Int, CaseIterable {
    case zone1 = 1, zone2, zone3, zone4, zone5

    var label: String {
        switch self {
        case .zone1: return "회복"
        case .zone2: return "지방 연소"
        case .zone3: return "유산소"
        case .zone4: return "무산소"
        case .zone5: return "최대"
        }
    }

    var shortLabel: String { "Z\(rawValue)" }

    static func from(bpm: Int, maxHR: Int = 200) -> HeartRateZone {
        let pct = Double(bpm) / Double(maxHR)
        switch pct {
        case ..<0.5: return .zone1
        case 0.5..<0.6: return .zone2
        case 0.6..<0.7: return .zone3
        case 0.7..<0.85: return .zone4
        default: return .zone5
        }
    }
}

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var workoutSession: HKWorkoutBuilder?

    @Published var currentHeartRate: Int = 0
    @Published var heartRateHistory: [Int] = []
    @Published var isAuthorized: Bool = false

    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let workoutType = HKObjectType.workoutType()

    var averageHeartRate: Int {
        guard !heartRateHistory.isEmpty else { return 0 }
        return heartRateHistory.reduce(0, +) / heartRateHistory.count
    }

    var maxHeartRate: Int {
        heartRateHistory.max() ?? 0
    }

    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }

        let readTypes: Set<HKObjectType> = [heartRateType, activeEnergyType, workoutType]
        let writeTypes: Set<HKSampleType> = [activeEnergyType, workoutType]

        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            await MainActor.run { self.isAuthorized = true }
            return true
        } catch {
            print("HealthKit 권한 요청 실패: \(error.localizedDescription)")
            return false
        }
    }

    func startHeartRateMonitoring() {
        let predicate = HKQuery.predicateForSamples(
            withStart: Date(),
            end: nil,
            options: .strictStartDate
        )

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.processHeartRateSamples(samples)
        }

        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.processHeartRateSamples(samples)
        }

        heartRateQuery = query
        healthStore.execute(query)
    }

    func stopHeartRateMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }

    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }

        let unit = HKUnit.count().unitDivided(by: .minute())

        for sample in heartRateSamples {
            let bpm = Int(sample.quantity.doubleValue(for: unit))
            DispatchQueue.main.async { [weak self] in
                self?.currentHeartRate = bpm
                self?.heartRateHistory.append(bpm)
                // 최대 500개 유지
                if let count = self?.heartRateHistory.count, count > 500 {
                    self?.heartRateHistory.removeFirst(count - 500)
                }
            }
        }
    }

    func startWorkout() async {
        let config = HKWorkoutConfiguration()
        config.activityType = .soccer
        config.locationType = .outdoor

        do {
            let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: config, device: .local())
            try await builder.beginCollection(at: Date())
            await MainActor.run { self.workoutSession = builder }
        } catch {
            print("워크아웃 시작 실패: \(error.localizedDescription)")
        }
    }

    func endWorkout() async -> Double {
        guard let builder = workoutSession else { return 0 }

        do {
            try await builder.endCollection(at: Date())
            try await builder.finishWorkout()

            // 칼로리 조회
            let predicate = HKQuery.predicateForSamples(
                withStart: builder.startDate,
                end: Date(),
                options: .strictStartDate
            )

            return await withCheckedContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: activeEnergyType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, result, _ in
                    let cal = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    continuation.resume(returning: cal)
                }
                healthStore.execute(query)
            }
        } catch {
            print("워크아웃 종료 실패: \(error.localizedDescription)")
            return 0
        }
    }

    func reset() {
        heartRateHistory.removeAll()
        currentHeartRate = 0
    }
}
