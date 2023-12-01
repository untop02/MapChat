import Foundation
import CoreLocation
import MapKit
import SwiftUI

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let description: String?
    var coordinate: CLLocationCoordinate2D
}

struct DetailOverlay: View {
    @Environment(\.colorScheme) var colorScheme
    let location: MapLocation
    @Binding var isPresented: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(colorScheme == .dark ? .black : .white)
            .frame(width: 200, height: 100)
            .overlay(
                VStack {
                    Text(location.name)
                    Text(location.description ?? "Description")
//                    Button("Close") {
//                        withAnimation {
//                            isPresented = false
//                        }
//                    }
                }
            )
            .shadow(radius: 10)
    }
}

struct MapLocationAnnotation: View {
    let location: MapLocation
    @State private var isDetailViewPresented = false
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
//                if isDetailViewPresented {
//                    DetailOverlay(location: location, isPresented: $isDetailViewPresented)
//                }
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                    .offset(x: 0, y: -5)
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isDetailViewPresented.toggle()
                }
            }
        }
        .overlay(
            Group {
                if isDetailViewPresented {
                    VStack {
                        DetailOverlay(location: location, isPresented: $isDetailViewPresented)
                            .onTapGesture {
                                withAnimation {
                                    isDetailViewPresented = false
                                }
                            }
                    }
                    .offset(x: 0, y: -70)
                }
            }
        )
    }
}
