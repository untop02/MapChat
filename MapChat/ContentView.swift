//
//  ContentView.swift
//  MapChat
//
//  Created by Unto Pulkkinen on 13.11.2023.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showingAlert = false
    @State private var isShowingOverlay = false
    @State private var isShowingSearch = false
    @State private var searchText = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: $viewModel.mapLocations) { location in
                MapAnnotation(coordinate: location.coordinate.wrappedValue) {
                    MapLocationAnnotation(location: location.wrappedValue)
                    
                }
            }
                .ignoresSafeArea()
                .accentColor(Color(.systemPink))
                .onAppear() {
                    viewModel.authorizationResult = nil
                    viewModel.centerMapOnUserLocation()
                }
                .alert(isPresented: Binding<Bool>(
                    get: {viewModel.authorizationResult != nil},
                    set: {_ in viewModel.authorizationResult = nil})
                ) {
                    switch viewModel.authorizationResult {
                    case .denied:
                        return Alert(
                            title: Text("Location Permission Denied"),
                            message: Text("Apps location permission denied"),
                            dismissButton: .default(Text("OK"))
                        )
                    case .restricted:
                        return Alert(
                            title: Text("Location Restricted"),
                            message: Text("Phones location restricted"),
                            dismissButton: .default(Text("OK"))
                        )
                    default:
                        return Alert(
                            title: Text("Default Title"),
                            message: Text("Default Message"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            if isShowingOverlay {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white).opacity(0.8)
                        .frame(width: 400, height: 810).padding()
                    VStack{
                        LocationsView(locations: LocationList.sampleData)
                                      .padding()

                    }
                    .padding()
                }
               
            }
            FloatingButtonsView(viewModel: viewModel, isShowingOverlay: $isShowingOverlay, isShowingSearch: $isShowingSearch, searchText: $searchText)
            WeatherView()
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
