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
    let locations: [LocationList]
  
    var body: some View {
        ScrollView {
            ForEach(locations) { location in
                CardView(location: location)
            }
        }
        .background(Color.clear)
        .padding()
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView(locations: LocationList.sampleData)
    }
}
