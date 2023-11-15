//
//  MapChatApp.swift
//  MapChat
//
//  Created by Unto Pulkkinen on 13.11.2023.
//

import SwiftUI
import MapKit
@main
struct MapChatApp: App {
    private let manager = CLLocationManager()
    init (){
        askForLocation()
    }
    func askForLocation(){
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
