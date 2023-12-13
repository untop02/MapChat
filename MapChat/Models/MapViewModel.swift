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
    // Function to load data from persistent storage
    private func loadData() {
        let fetchRequest: NSFetchRequest<Marker> = Marker.fetchRequest()
        
        do {
            let mapMarkers = try managedObjectContext.fetch(fetchRequest)
            for marker in mapMarkers {
                mapLocations.insert(MapLocation(title: marker.title, description: marker.text, coordinate: CLLocationCoordinate2D(latitude: marker.coordLat, longitude: marker.coordLong)), at: 0)
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    // Map setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    // Function to center the map on user
    func centerMapOnUserLocation() {
        if let userLocation = locationManager.location {
            updateUserRegion(userLocation)
        }
    }
    // Function to create mapmarker
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
        mapLocations.insert(MapLocation(title: newMapMarker.title, description: newMapMarker.text, coordinate: CLLocationCoordinate2D(latitude: newMapMarker.coordLat, longitude: newMapMarker.coordLong)), at: 0)
    }
    // Function to remove mapmarker
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
    //  Converts CLLocationCoordinate2D to CLLocation.
    func coordToLoc(coord: CLLocationCoordinate2D) -> CLLocation{
        let getLat: CLLocationDegrees = coord.latitude
        let getLon: CLLocationDegrees = coord.longitude
        let newLoc: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
        return newLoc
    }
    //  Updates the map view's region based on the provided user's location.
    func updateUserRegion(_ userLocation: CLLocation) {
        let newRegion = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MapDetails.defaultSpan
        )
        self.region = newRegion
    }
    //  Updates the user's region based on the most recent location received by the location manager.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            self.updateUserRegion(userLocation)
        }
    }
    //  Handles changes in the authorization status for location services and updates the app's authorization result.
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
}
