/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI
import MapKit

struct CardView: View {
    let location: MapLocation
    @ObservedObject var viewModel: MapViewModel
    private let locationManager = CLLocationManager()
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        Button(action: {
            viewModel.updateUserRegion(viewModel.coordToLoc(coord: location.coordinate))
            
        }){
            VStack(alignment: .leading) {
                Text(location.title ?? "")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                HStack {
                    Text(location.description ?? "")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Spacer()
                    let distanceInMeters = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        .distance(from: locationManager.location ?? CLLocation(latitude: 60.19, longitude: 24.94))
                    let formattedDistance = formatDistance(distanceInMeters)
                    Label(formattedDistance, systemImage: "figure.walk")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .font(.caption)
            }
            .padding()
        }
    }
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2

        if distance > 1000 {
            let converted = distanceMeasurement.converted(to: .kilometers)
            return formatter.string(from: converted)
        }else {
            return formatter.string(from: distanceMeasurement)
        }
    }
}
