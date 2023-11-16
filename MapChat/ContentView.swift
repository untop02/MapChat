//
//  ContentView.swift
//  MapChat
//
//  Created by Unto Pulkkinen on 13.11.2023.
//

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                .ignoresSafeArea()
                .accentColor(Color(.systemPink))
                .onAppear() {
                    viewModel.checkIfLocationServicesEnabled()
                }
            Button(action: {
                viewModel.centerMapOnUserLocation()
            }) {
                Image(systemName: "location.north.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .position()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
