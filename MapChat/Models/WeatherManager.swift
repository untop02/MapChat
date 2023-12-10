//
//  Weathermanager.swift
//  MapChat
//
//  Created by Niilou on 26.11.2023.
//

import Foundation
import CoreLocation
import SwiftUI

enum LocationError: Error {
    case noLocationAvailable
}
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
}

class WeatherLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Creating an instance of CLLocationManager, the framework we use to get the coordinates
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var isLoading = false
    @Published var imageURL: URL?
    var baseUrl = "https://openweathermap.org/img/wn/"

    override init() {
        super.init()
        // Assigning a delegate to our CLLocationManager instance
        manager.delegate = self
        requestLocation()
    }
    
    // Requests the one-time delivery of the user’s current location, see https://developer.apple.com/documentation/corelocation/cllocationmanager/1620548-requestlocation
    func requestLocation() {
        isLoading = true
        manager.requestLocation()
    }
    
    // Set the location coordinates to the location variable
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    
    // This function will be called if we run into an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location", error)
        isLoading = false
    }
    
    func getCurrentWeather() async throws -> ResponseBody {
        guard let latitude = location?.latitude, let longitude = location?.longitude else {
            throw LocationError.noLocationAvailable
        }

        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\("fe596d241a3491e56d8e97cc1eb9b5cd")&units=metric") else {
            throw NetworkError.invalidURL
        }

        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        let iconURL = URL(string: baseUrl + (decodedData.weather.first?.icon ?? "") + "@2x.png")
        DispatchQueue.main.async {
            self.isLoading = false
            self.imageURL = iconURL
        }
        print(decodedData)
        return decodedData
    }
}

struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var wind: WindResponse
    var visibility: Int
    var name: String
    var id: Int
    var base: String
    var dt: Int
    var timezone: Int
    var cod: Int
    
    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }

    struct WeatherResponse: Decodable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }

    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Int
        var humidity: Int
    }
    
    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }
}
