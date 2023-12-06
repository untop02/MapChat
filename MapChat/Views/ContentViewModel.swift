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

final class ContentViewModel: ObservableObject {
    private var cancellable: AnyCancellable?

    @Published var cityText = "" {
        didSet {
            searchForCity(text: cityText)
        }
    }
    
    @Published var poiText = "" {
        didSet {
            searchForPOI(text: poiText)
        }
    }
    
    @Published var viewData = [LocalSearchViewData]()

    var service: LocalSearchService
    
    init() {
        let center = CLLocationCoordinate2D(latitude: 60.2239, longitude: 24.7)
        service = LocalSearchService(in: center)
        
        cancellable = service.localSearchPublisher.sink { mapItems in
            self.viewData = mapItems.map({ LocalSearchViewData(mapItem: $0) })
        }
    }
    
    private func searchForCity(text: String) {
        service.searchCities(searchText: text)
    }
    
    private func searchForPOI(text: String) {
        service.searchPointOfInterests(searchText: text)
    }
}
