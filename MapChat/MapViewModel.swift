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
struct MapLocation: Identifiable {
    let id = UUID()
    let name: String?
    let description: String?
    var coordinate: CLLocationCoordinate2D
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
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
        //loadTestData()
    }
    
    private func loadTestData() {
        mapLocations = [MapLocation(name: "Test", description: "Best koulu", coordinate: CLLocationCoordinate2D(latitude: 60.2239, longitude: 24.758807))]
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
    
    func createMapMarker() {
        if let userLocation = locationManager.location {
            let newLocation = MapLocation(name: nil, description: nil, coordinate: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
            mapLocations.append(newLocation)
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
