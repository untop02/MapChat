import Foundation
import CoreLocation
import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 60.2239, longitude: 24.758807)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
}
enum AuthorizationResult: Equatable {
    case denied
    case restricted
    case authorized
}
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion
    @Published var authorizationResult: AuthorizationResult?
    
    private let locationManager = CLLocationManager()
    
    @Published var locationCord: CLLocationCoordinate2D?
    override init() {
        self.region = MKCoordinateRegion(
            center: MapDetails.startingLocation,
            span: MapDetails.defaultSpan
        )
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        requestLocationAuthorization()
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocationAuthorization()
    }
    
    func centerMapOnUserLocation() {
        // TODO: Aiheuttaa [SwiftUI] Publishing changes from within view updates is not allowed, this will cause undefined behavior.
        if let userLocation = locationManager.location {
            updateUserRegion(userLocation)
        }
    }
    
    private func updateUserRegion(_ userLocation: CLLocation) {
        let newRegion = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MapDetails.defaultSpan
        )
        DispatchQueue.main.async {
            self.region = newRegion
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            updateUserRegion(userLocation)
        }
    }
    private func requestLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            authorizationResult = .restricted
        case .denied:
            authorizationResult = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            if let userLocation = locationManager.location { updateUserRegion(userLocation) }
        @unknown default:
            break
        }
    }
    
}
