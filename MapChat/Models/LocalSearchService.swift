//
//  LocalSearchService.swift
//  MapChat
//
//  Created by iosdev on 4.12.2023.
//

import Foundation
import Combine
import MapKit
import SwiftUI

//Searches map based on input
final class LocalSearchService {
    let localSearchPublisher = PassthroughSubject<[MKMapItem], Never>()
    private let center: CLLocationCoordinate2D
    private let radius: CLLocationDistance
    

    init(in center: CLLocationCoordinate2D,
         radius: CLLocationDistance = 350_000) {
        //center is sent from SearchViewModel, currently set to Helsinki because nowhere else matters
        self.center = center
        self.radius = radius
    }
    
    public func searchCities(searchText: String) {
        request(resultType: .address, searchText: searchText)
    }
    
    public func searchPointOfInterests(searchText: String) {
        request(searchText: searchText)
    }
    
    private func request(resultType: MKLocalSearch.ResultType = .pointOfInterest,
                         searchText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.pointOfInterestFilter = .includingAll
        request.resultTypes = resultType
        //gives relevent results in region, if to be used outside finland change region from static to user location
        request.region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: radius,
                                            longitudinalMeters: radius)
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self](response, _) in
            guard let response = response else {
                return
            }
            //sends results back to be used
            self?.localSearchPublisher.send(response.mapItems)
        }
    }
}
