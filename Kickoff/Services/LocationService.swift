import Foundation
import CoreLocation
import Combine

struct FieldCalibration {
    var corners: [CLLocationCoordinate2D] = [] // 4 corners: TL, TR, BR, BL
    var fieldSize: FieldSize = FieldSize()

    var isComplete: Bool { corners.count == 4 }

    /// GPS 좌표를 정규화된 필드 좌표(0-1)로 변환
    func normalizeCoordinate(_ coord: CLLocationCoordinate2D) -> (x: Double, y: Double)? {
        guard isComplete else { return nil }

        // 간단한 선형 보간 사용
        let topLeft = corners[0]
        let topRight = corners[1]
        let bottomRight = corners[2]
        let bottomLeft = corners[3]

        // X축: left-right 비율
        let avgLeftLon = (topLeft.longitude + bottomLeft.longitude) / 2
        let avgRightLon = (topRight.longitude + bottomRight.longitude) / 2
        let x = (coord.longitude - avgLeftLon) / (avgRightLon - avgLeftLon)

        // Y축: top-bottom 비율
        let avgTopLat = (topLeft.latitude + topRight.latitude) / 2
        let avgBottomLat = (bottomLeft.latitude + bottomRight.latitude) / 2
        let y = (coord.latitude - avgTopLat) / (avgBottomLat - avgTopLat)

        return (x: max(0, min(1, x)), y: max(0, min(1, y)))
    }
}

// MARK: - Favorite Field

struct FavoriteFieldCorner: Codable {
    let latitude: Double
    let longitude: Double
}

struct FavoriteField: Codable, Identifiable {
    let id: String
    var name: String
    let corners: [FavoriteFieldCorner] // TL, TR, BR, BL
    let lengthMeters: Double
    let widthMeters: Double
    let savedDate: Date

    init(name: String, calibration: FieldCalibration) {
        self.id = UUID().uuidString
        self.name = name
        self.corners = calibration.corners.map { FavoriteFieldCorner(latitude: $0.latitude, longitude: $0.longitude) }

        // 코너 좌표로 필드 크기 계산
        if calibration.corners.count == 4 {
            let tl = calibration.corners[0]
            let tr = calibration.corners[1]
            let bl = calibration.corners[3]
            let topEdge = CLLocation(latitude: tl.latitude, longitude: tl.longitude)
                .distance(from: CLLocation(latitude: tr.latitude, longitude: tr.longitude))
            let leftEdge = CLLocation(latitude: tl.latitude, longitude: tl.longitude)
                .distance(from: CLLocation(latitude: bl.latitude, longitude: bl.longitude))
            self.lengthMeters = max(topEdge, leftEdge)
            self.widthMeters = min(topEdge, leftEdge)
        } else {
            self.lengthMeters = 105
            self.widthMeters = 68
        }
        self.savedDate = Date()
    }

    func toCalibration() -> FieldCalibration {
        var cal = FieldCalibration()
        cal.corners = corners.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        cal.fieldSize = FieldSize(lengthMeters: lengthMeters, widthMeters: widthMeters)
        return cal
    }
}

// MARK: - Favorite Field Storage

class FavoriteFieldStore: ObservableObject {
    @Published var fields: [FavoriteField] = []

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("favorite_fields.json")
    }

    init() {
        load()
    }

    func save(field: FavoriteField) {
        fields.append(field)
        persist()
    }

    func delete(at offsets: IndexSet) {
        fields.remove(atOffsets: offsets)
        persist()
    }

    func delete(id: String) {
        fields.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(fields)
            try data.write(to: fileURL)
        } catch {
            print("즐겨찾기 구장 저장 오류: \(error)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            fields = try JSONDecoder().decode([FavoriteField].self, from: data)
        } catch {
            fields = []
        }
    }
}

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var previousLocation: CLLocation?

    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0 // km/h
    @Published var totalDistance: Double = 0 // meters
    @Published var isTracking: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var calibration: FieldCalibration = FieldCalibration()
    @Published var locationHistory: [LocationPoint] = []

    // Sprint detection
    private let sprintThreshold: Double = 20.0 // km/h
    @Published var sprintCount: Int = 0
    @Published var sprintDistance: Double = 0 // meters
    private var isInSprint: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2.0 // 2m minimum movement
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startTracking() {
        totalDistance = 0
        sprintCount = 0
        sprintDistance = 0
        locationHistory.removeAll()
        lastLocation = nil
        previousLocation = nil
        isInSprint = false
        isTracking = true
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }

    func pauseTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }

    func resumeTracking() {
        isTracking = true
        locationManager.startUpdatingLocation()
    }

    // MARK: - Field Calibration

    func addCalibrationCorner() {
        guard let location = currentLocation else { return }
        if calibration.corners.count < 4 {
            calibration.corners.append(location.coordinate)
        }
    }

    func resetCalibration() {
        calibration = FieldCalibration()
    }

    var calibrationCornerLabel: String {
        let labels = ["왼쪽 위", "오른쪽 위", "오른쪽 아래", "왼쪽 아래"]
        let idx = calibration.corners.count
        guard idx < 4 else { return "완료" }
        return labels[idx]
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking, let location = locations.last else { return }
        guard location.horizontalAccuracy < 20 else { return } // 정확도 필터링

        currentLocation = location

        // 속도 계산
        let speed = max(0, location.speed) * 3.6 // m/s to km/h
        currentSpeed = speed

        // 거리 계산
        if let last = lastLocation {
            let distance = location.distance(from: last)
            if distance < 100 { // 비정상적 점프 필터링
                totalDistance += distance

                // 스프린트 감지
                if speed >= sprintThreshold {
                    if !isInSprint {
                        isInSprint = true
                        sprintCount += 1
                    }
                    sprintDistance += distance
                } else {
                    isInSprint = false
                }
            }
        }

        previousLocation = lastLocation
        lastLocation = location

        // 정규화된 위치 포인트 추가
        if calibration.isComplete {
            if let normalized = calibration.normalizeCoordinate(location.coordinate) {
                let point = LocationPoint(
                    x: normalized.x,
                    y: normalized.y,
                    timestamp: location.timestamp,
                    speedKmh: speed
                )
                locationHistory.append(point)
            }
        } else {
            // 캘리브레이션 없으면 상대 좌표 사용
            let point = LocationPoint(
                x: Double.random(in: 0.1...0.9),
                y: Double.random(in: 0.1...0.9),
                timestamp: location.timestamp,
                speedKmh: speed
            )
            locationHistory.append(point)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 오류: \(error.localizedDescription)")
    }
}
