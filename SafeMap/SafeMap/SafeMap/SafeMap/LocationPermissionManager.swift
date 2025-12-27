import Foundation
import CoreLocation

final class LocationPermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var isAuthorized: Bool = false

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        checkStatus()
    }

    func checkStatus() {
        let status = manager.authorizationStatus
        isAuthorized = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkStatus()
    }
}

