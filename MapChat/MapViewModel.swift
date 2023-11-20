import CoreLocation
import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 60.2239, longitude: 24.758807)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: MapDetails.startingLocation,
        span: MapDetails.defaultSpan)
    
    var locationManager: CLLocationManager?
    
    private func setupLocationManager() {
        guard let locationManager = locationManager else { return }
        locationManager.delegate = self
        checkIfLocationServicesEnabled()
    }
    
    func centerMapOnUserLocation() {
            guard let locationManager = locationManager, let userLocation = locationManager.location else { return }

            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MapDetails.defaultSpan
            )
        }
    
    func checkIfLocationServicesEnabled() {
        //This method can cause UI unresponsiveness if invoked on the main thread fix
        DispatchQueue.global(qos: .userInitiated).async {
            guard CLLocationManager.locationServicesEnabled() else {
                // Update UI on the main thread
                DispatchQueue.main.async {
                    print("Location Services off!")
                }
                return
            }
            DispatchQueue.main.async {
                self.locationManager = CLLocationManager()
                self.requestLocationAuthorization()
            }
        }
    }

    
    private func requestLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted")
        case .denied:
            print("You have denied this app location permission.")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MapDetails.defaultSpan)
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocationAuthorization()
    }
}
