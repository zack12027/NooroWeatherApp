//
//  WeatherApiService.swift
//  NooroWeatherApp
//
//  Created by Weng Seong Cheang on 12/9/24.
//
import Foundation

// MARK: - WeatherService Protocol
protocol WeatherService {
    func searchLocations(for query: String) async throws -> [LocationSearchResult]
    func fetchWeather(for location: LocationSearchResult) async throws -> WeatherModel
}

// MARK: - LocationPersistenceService Protocol
protocol LocationPersistenceService {
    func saveLocation(_ location: LocationSearchResult)
    func loadSavedLocation() -> LocationSearchResult?
    //func clearDefaults()
}

// MARK: - WeatherAPIService Implementation
class WeatherAPIService: WeatherService {
    private let apiKey = "8ebeb31f9a23407a87e221559240712"

    func searchLocations(for query: String) async throws -> [LocationSearchResult] {
        guard !query.isEmpty else { return [] }
        
        let urlString = "https://api.weatherapi.com/v1/search.json?key=\(apiKey)&q=\(query)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([LocationSearchResult].self, from: data)
    }

    func fetchWeather(for location: LocationSearchResult) async throws -> WeatherModel {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(location.name)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherModel.self, from: data)
    }
}

// MARK: - UserDefaultsLocationService Implementation
class UserDefaultsLocationService: LocationPersistenceService {
    private let userDefaultsKey = "SelectedLocation"

    func saveLocation(_ location: LocationSearchResult) {
        do {
            let encodedData = try JSONEncoder().encode(location)
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print("Error saving location: \(error)")
        }
    }

    func loadSavedLocation() -> LocationSearchResult? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(LocationSearchResult.self, from: data)
    }
    //Testing purposes
    /*
    func clearDefaults() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
     */
}





