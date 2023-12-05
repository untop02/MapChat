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
    var baseUrl = "https://openweathermap.org/img/wn/"
    
    var body: some View {
        HStack() {
            if let weather = weatherData {
                HStack {
                    AsyncImage(url: URL(string: baseUrl + (weather.weather.first?.icon ?? "") + "@2x.png"))
                        .frame(maxWidth: 50, maxHeight: 50)
                }
                HStack {
                    VStack {
                        Text("Location: \(weather.name)")
                        Text("Temperature: \(weather.main.temp.description)")
                        Text("Feels like: \(weather.main.feels_like.description)")
                    }
                }
                Button(action: {
                    weatherManager.requestLocation()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                }
            }
        }
        .frame(width: 250, height: 80)
        .background(.clear)
        .onChange(of: isAuthorized) { newValue in
            if newValue {
                hasLocation = false
                weatherManager.requestLocation()
                fetchWeather()
            }
        }
        .onReceive(weatherManager.$location) { location in
            if location != nil {
                hasLocation = true
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

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(isAuthorized: .constant(true))
    }
}
