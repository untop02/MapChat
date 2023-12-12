import Foundation
import CoreLocation
import MapKit
import SwiftUI

struct MapLocation: Identifiable {
    let id = UUID()
    let title: String?
    let description: String?
    var coordinate: CLLocationCoordinate2D
}

struct DetailOverlay: View {
    @Environment(\.colorScheme) var colorScheme
    let location: MapLocation
    @Binding var isPresented: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
            .frame(width: 300, height: 150)
            .overlay(
                VStack(spacing: 5) {
                    Text(location.title ?? "Title")
                        .padding(.bottom, 5)
                    Text(location.description ?? "Description")
                }
                    .padding()
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
                    .offset(y: -98)
                }
            }
        )
    }
}
