// 
//   ContentView.swift
//   MapChat
// 
//   Created by Unto Pulkkinen on 13.11.2023.
// 

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showingAlert = false
    @State private var isShowingOverlay = false
    @State private var isShowingSearch = false
    @State private var searchText = ""
    @State private var isAuthorized = false
    @Environment(\.colorScheme) var colorScheme
    
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
                .alert(isPresented: $showingAlert) {
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
                        return Alert(title: Text(""), dismissButton: .default(Text(""))
                        )
                    }
                }
            if isShowingOverlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(colorScheme == .dark ? Color(uiColor: .systemGray6) : .white)
                            .opacity(0.8)
                        VStack {
                            LocationsView(locations: $viewModel.mapLocations, viewModel: viewModel)
                        }
                        .padding(.top, 80)
                }
                    .ignoresSafeArea()
            }
            FloatingButtonsView(mapViewModel: viewModel, isShowingOverlay: $isShowingOverlay, isShowingSearch: $isShowingSearch, searchText: $searchText, isAuthorized: $isAuthorized)
        }
        .onChange(of: viewModel.authorizationResult) { newValue in
            if newValue == .authorized {
                isAuthorized = true
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            MapView()
        }
    }
}
