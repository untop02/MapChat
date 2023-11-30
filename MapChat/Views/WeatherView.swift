//
//  WeatherView.swift
//  MapChat
//
//  Created by iosdev on 30.11.2023.
//

import SwiftUI

struct WeatherView: View {
    @StateObject var weatherManager = WeatherLocationManager()
    @State private var weatherData: ResponseBody?

    var body: some View {
        VStack {
            if weatherManager.isLoading {
                ProgressView()
                    .padding()
            } else if let weather = weatherData {
                // Display weather information here
                Text("Temperature: \(weather.main.temp)")
                    .padding()
                // Display more weather details as needed
            } else {
                Text("Weather data not available")
                    .padding()
            }
            Button("Request Location") {
                weatherManager.requestLocation()
            }
            Button("Fetch Weather") {
                fetchWeather()
            }
            .padding()
        }
    }

    private func fetchWeather() {
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
