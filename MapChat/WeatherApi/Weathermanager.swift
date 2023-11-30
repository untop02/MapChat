    //
    //  Weathermanager.swift
    //  MapChat
    //
    //  Created by Niilou on 26.11.2023.
    //

    import Foundation
    import CoreLocation


    class WeatherLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
        // Creating an instance of CLLocationManager, the framework we use to get the coordinates
        let manager = CLLocationManager()
        
        @Published var location: CLLocationCoordinate2D?
        @Published var isLoading = false
        
        override init() {
            super.init()
            
            // Assigning a delegate to our CLLocationManager instance
            manager.delegate = self
        }
        
        // Requests the one-time delivery of the user’s current location, see https://developer.apple.com/documentation/corelocation/cllocationmanager/1620548-requestlocation
        func requestLocation() {
            isLoading = true
            manager.requestLocation()
        }
        
        // Set the location coordinates to the location variable
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            location = locations.first?.coordinate
            isLoading = false
        }
        
        // This function will be called if we run into an error
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error getting location", error)
            isLoading = false
        }
        
        func getCurrentWeather() async throws -> ResponseBody {
                guard let latitude = location?.latitude,
                      let longitude = location?.longitude else {
                    fatalError("No location available")
                }
            
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\("fe596d241a3491e56d8e97cc1eb9b5cd")&unitsmetric") else { fatalError("Missing URL")}
            
            let urlRequest = URLRequest(url: url)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error fetching weather data") }
            let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
            
            return decodedData
        }
    }

    struct ResponseBody: Decodable {
        var coord: CoordinatesResponse
        var weather: [WeatherResponse]
        var main: MainResponse
        var name: String
        var wind: WindResponse

        struct CoordinatesResponse: Decodable {
            var lon: Double
            var lat: Double
        }

        struct WeatherResponse: Decodable {
            var id: Double
            var main: String
            var description: String
            var icon: String
        }

        struct MainResponse: Decodable {
            var temp: Double
            var feels_like: Double
            var temp_min: Double
            var temp_max: Double
            var pressure: Double
            var humidity: Double
        }
        
        struct WindResponse: Decodable {
            var speed: Double
            var deg: Double
        }
    }

    extension ResponseBody.MainResponse {
        var feelsLike: Double { return feels_like }
        var tempMin: Double { return temp_min }
        var tempMax: Double { return temp_max }
    }
