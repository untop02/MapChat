//
//  ContentViewModel.swift
//  MapChat
//
//  Created by iosdev on 4.12.2023.
//
import Foundation
import MapKit
import Combine


struct LocalSearchViewData: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var center: CLLocationCoordinate2D
    
    init(mapItem: MKMapItem) {
        self.title = mapItem.name ?? ""
        self.subtitle = mapItem.placemark.title ?? ""
        self.center = mapItem.placemark.coordinate
    }
}
//Class to control map search text input
final class ContentViewModel: ObservableObject {
    private var cancellable: AnyCancellable?
    private var timer = Timer()


    @Published var cityText = "" {
        //runs for every input
        didSet {
            //resets delay to make sure old request is ignored
            timer.invalidate()
            //initiates a half second delay before running searchForCity funcition
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchForCity), userInfo: nil, repeats: false)
        }
    }
    
    @Published var poiText = "" {
        //runs for every input
        didSet {
            //resets delay to make sure old request is ignored
            timer.invalidate()
            //initates a half second delay before running searchForPOI function
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchForPOI), userInfo: nil, repeats: false)
        }
    }
    //list of returned search data
    @Published var viewData = [LocalSearchViewData]()

    var service: LocalSearchService
    
    init() {
        //sets helsinki as reference for search, Suomi #1
        let center = CLLocationCoordinate2D(latitude: 60.2239, longitude: 24.7)
        service = LocalSearchService(in: center)
        
        cancellable = service.localSearchPublisher.sink { mapItems in
            self.viewData = mapItems.map({ LocalSearchViewData(mapItem: $0) })
        }
    }
    func clearSearch(){
        cityText = ""
        poiText = ""
    }
    @objc private func searchForCity() {
        service.searchCities(searchText: cityText)
    }
    
    @objc private func searchForPOI() {
        service.searchPointOfInterests(searchText: poiText)
    }
}
