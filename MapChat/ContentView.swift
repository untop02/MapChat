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
    @State private var showingAlert = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: $viewModel.mapLocations,
                annotationContent: { location in
                MapMarker(coordinate: location.coordinate.wrappedValue, tint: .red)
            })
            .ignoresSafeArea()
            .accentColor(Color(.systemPink))
            .onAppear() {
                viewModel.authorizationResult = nil
                viewModel.centerMapOnUserLocation()
            }
            .onChange(of: viewModel.authorizationResult) { newAuthResult in
                switch newAuthResult {
                case .denied, .restricted:
                    showingAlert = true
                default:
                    showingAlert = false
                }
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
                    return Alert(
                        title: Text("Default Title"),
                        message: Text("Default Message"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            VStack(){
                HStack(){
                    Button(action: {
                        print("da menu")
                    }) {
                        Image(systemName: "list.bullet").font(.system(size: 35)).foregroundColor(Color.black)}
                    Spacer()
                    Button(action: {
                        print("looking for you")
                    }) {
                        Image(systemName: "magnifyingglass").font(.system(size: 25)).foregroundColor(Color.black).frame(width: 45, height: 45).overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )}
                }.padding()
                Spacer()
                HStack(){
                    Button(action: {
                        viewModel.centerMapOnUserLocation()
                    }) {
                        Image(systemName: "location.north.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32).padding()
                        Spacer()
                        Button(action: {
                            print("plus perfect")
                            viewModel.createMapMarker()
                        }) {
                            Image(systemName: "plus").font(.system(size: 30))
                                .frame(width: 85, height: 85)
                                .foregroundColor(Color.black)
                                .background(Color.white)
                                .clipShape(Circle())
                        }}.padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
