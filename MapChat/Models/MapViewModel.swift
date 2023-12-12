import CoreLocation
import MapKit
import CoreData

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 60.2239, longitude: 24.758807)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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
    private let managedObjectContext = CoreDataStack.shared.viewContext
    
    override init() {
        self.region = MKCoordinateRegion(
            center: MapDetails.startingLocation,
            span: MapDetails.defaultSpan
        )
        super.init()
        setupLocationManager()
        loadData()
    }
    private func loadData() {
        let fetchRequest: NSFetchRequest<Marker> = Marker.fetchRequest()
        
        do {
            let mapMarkers = try managedObjectContext.fetch(fetchRequest)
            for marker in mapMarkers {
                mapLocations.append(MapLocation(title: marker.title, description: marker.text, coordinate: CLLocationCoordinate2D(latitude: marker.coordLat, longitude: marker.coordLong)))
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func centerMapOnUserLocation() {
        if let userLocation = locationManager.location {
            updateUserRegion(userLocation)
        }
    }
    
    func createMapMarker(title: String?, description: String?) {
        guard let userLocation = locationManager.location else {
            return
        }
        
        let newMapMarker = Marker(context: managedObjectContext)
        newMapMarker.title = title
        newMapMarker.text = description
        newMapMarker.coordLat = userLocation.coordinate.latitude
        newMapMarker.coordLong = userLocation.coordinate.longitude
        newMapMarker.timeAndDate = Date()
        
        do {
            try managedObjectContext.save()
            print("did it")
        } catch let error as NSError {
            print("Error saving data: \(error.localizedDescription)")
        }
        mapLocations.append(MapLocation(title: newMapMarker.title, description: newMapMarker.text, coordinate: CLLocationCoordinate2D(latitude: newMapMarker.coordLat, longitude: newMapMarker.coordLong)))
    }
    func deleteItem(at index: Int) {
        let fetchRequest: NSFetchRequest<Marker> = Marker.fetchRequest()
        
        do {
            let mapMarkers = try managedObjectContext.fetch(fetchRequest)
            if index < mapLocations.count {
                let markerToDelete = mapMarkers[index]
                managedObjectContext.delete(markerToDelete)
                mapLocations.remove(at: index)
                do {
                    try managedObjectContext.save()
                } catch {
                    print("Error saving context after deletion: \(error.localizedDescription)")
                }
            } else {
                print("Index out of range")
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    
    func coordToLoc(coord: CLLocationCoordinate2D) -> CLLocation{
        let getLat: CLLocationDegrees = coord.latitude
        let getLon: CLLocationDegrees = coord.longitude
        let newLoc: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
        return newLoc
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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("rest")
            authorizationResult = .restricted
        case .denied:
            print("denied")
            authorizationResult = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            if let userLocation = locationManager.location {
                print("auth")
                authorizationResult = .authorized
                updateUserRegion(userLocation)
            }
        default:
            break
        }
    }
    internal func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            mapView.deselectAnnotation(view.annotation, animated: false)
            return
        }
        
    }
}
