// 
//   LocationsView.swift
//   MapChat
// 
//   Created by Unto Pulkkinen on 26.11.2023.
// 

import SwiftUI

// list for points of interest
struct LocationsView: View {
    @Binding var locations: [MapLocation]
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if locations.isEmpty {
            EmptyListView()
        } else {
            List {
                ForEach(locations) { location in
                    CardView(location: location, viewModel: viewModel)
                        .listRowBackground(colorScheme == .dark ? Color(uiColor: .systemGray6) : .white)
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        viewModel.deleteItem(at: index)
                    }
                }
                .listRowSeparator(.visible)
            }
            .scrollContentBackground(.hidden)
        }
    }
}

struct EmptyListView: View {
    var body: some View {
        Text("No locations available")
            .foregroundColor(.secondary)
            .padding()
    }
}
