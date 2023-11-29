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
    // TODO: Aiheuttaa [SwiftUI] Publishing changes from within view updates is not allowed, this will cause undefined behavior.
    @Published var region: MKCoordinateRegion
    @Published var authorizationResult: AuthorizationResult?
    @Published var mapLocations: [MapLocation] = []
    private let locationManager = CLLocationManager()
    
    override init() {
        self.region = MKCoordinateRegion(
            center: MapDetails.startingLocation,
            span: MapDetails.defaultSpan
        )
        super.init()
        setupLocationManager()
        loadTestData()
    }
    
    private func loadTestData() {
        mapLocations = [MapLocation(name: "Koulu", description: "Best koulu", coordinate: CLLocationCoordinate2D(latitude: 60.2239, longitude: 24.758807))]
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        requestLocationAuthorization()
    }

    func centerMapOnUserLocation() {
        if let userLocation = locationManager.location {
            updateUserRegion(userLocation)
        }
    }
    
    func createMapMarker(name: String?, description: String?) {
        if let userLocation = locationManager.location {
            let newLocation = MapLocation(name: name, description: description, coordinate: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
            mapLocations.append(newLocation)
        }
    }
    
    func updateUserRegion(_ userLocation: CLLocation) {
        let newRegion = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MapDetails.defaultSpan
        )
            self.region = newRegion
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            self.updateUserRegion(userLocation)
        }
    }
    private func requestLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.async {
                self.authorizationResult = .restricted
            }
        case .denied:
            DispatchQueue.main.async {
                self.authorizationResult = .denied
            }
        case .authorizedAlways, .authorizedWhenInUse:
            if let userLocation = locationManager.location {
                self.updateUserRegion(userLocation)
            }
        @unknown default:
            break
        }
    }
}
