//
//  ContentView.swift
//  MapChat
//
//  Created by Unto Pulkkinen on 13.11.2023.
//

import MapKit
import SwiftUI

struct ContentView: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    var body: some View {
        ZStack(alignment: .bottom){
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
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
                    Spacer()
                    Button(action: {
                        print("plus perfect")
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
