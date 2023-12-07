//
//  LocationsView.swift
//  MapChat
//
//  Created by Unto Pulkkinen on 26.11.2023.
//

/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI

struct LocationsView: View {
   @Binding var locations: [MapLocation]
    @ObservedObject var viewModel: MapViewModel
  
    var body: some View {
        ScrollView {
            ForEach(locations) { location in
                CardView(location: location, viewModel: viewModel)
            }
        }
        .background(Color.clear)
        .padding()
    }
}
