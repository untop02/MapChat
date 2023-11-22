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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(viewModel: viewModel)
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
            if isShowingOverlay {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white).opacity(0.8)
                    .frame(width: 400, height: 810).padding()
            }
            FloatingButtonsView(viewModel: viewModel, isShowingOverlay: $isShowingOverlay)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
