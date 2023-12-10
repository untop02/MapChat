/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI
import MapKit

struct CardView: View {
    let location: MapLocation
    @ObservedObject var viewModel: MapViewModel
    private let locationManager = CLLocationManager()
    
    
    var body: some View {
        
        Button(action: {
            viewModel.updateUserRegion(viewModel.coordToLoc(coord: location.coordinate))
            
        }){
            VStack(alignment: .leading) {
                Text(location.title ?? "")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(.black)
                Spacer()
                HStack {
                    Text(location.description ?? "")
                        .foregroundColor(.black)
                    Spacer()
                    Label("\(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).distance(from: locationManager.location ?? CLLocation(latitude:60.19, longitude: 24.94))) m", systemImage: "figure.walk")
                        .foregroundColor(.black)
                }
                .font(.caption)
            }.padding()
            
            
        }
    }
}
