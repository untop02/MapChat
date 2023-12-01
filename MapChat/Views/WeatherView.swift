//
//  WeatherView.swift
//  MapChat
//
//  Created by iosdev on 30.11.2023.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherManager = WeatherLocationManager()
    @State private var weatherData: ResponseBody?
    @Binding var isAuthorized: Bool
    @State private var hasLocation = false
    
    var body: some View {
        VStack {
            if weatherManager.isLoading {
                ProgressView()
                    .padding()
            } else if let weather = weatherData {
                Text("Temperature: \(weather.main.temp)")
                    .padding()
            } else {
                Text("Weather data not available \(isAuthorized.description)")
                    .padding()
            }
            Button("Request Location") {
                weatherManager.requestLocation()
            }
            .padding()
        }
        .onChange(of: isAuthorized) { newValue in
            if newValue {
                hasLocation = false
                weatherManager.requestLocation()
                fetchWeather()
            }
        }
        .onReceive(weatherManager.$location) { location in
            if let newLocation = location {
                hasLocation = true
                print("Location obtained:", newLocation)
                fetchWeather()
            }
        }
    }
    
    private func fetchWeather() {
        guard isAuthorized, hasLocation else {
            return
        }
        
        Task {
            do {
                let weather = try await weatherManager.getCurrentWeather()
                weatherData = weather
            } catch {
                print("Error fetching weather: \(error)")
            }
        }
    }
}
