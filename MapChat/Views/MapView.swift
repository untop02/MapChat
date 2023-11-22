//
//  MapView.swift
//  MapChat
//
//  Created by iosdev on 22.11.2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: $viewModel.mapLocations) { location in
            MapMarker(coordinate: location.coordinate.wrappedValue, tint: .red)
        }
    }
}
