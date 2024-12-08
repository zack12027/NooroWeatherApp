//
//  WeatherViewModel.swift
//  NooroWeatherApp
//
//  Created by Weng Seong Cheang on 12/7/24.
//

import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var searchResults: [LocationSearchResult] = []
    @Published var cachedWeather: [Int: WeatherModel] = [:]
    @Published var selectedWeather: WeatherModel?
    private let apiKey = "8ebeb31f9a23407a87e221559240712"
    private let userDefaultsKey = "SelectedLocation"
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var isLoading = false
    
    
    init() {
        setupSearchSubscriber()
        loadSavedLocation()
    }
    
    private func setupSearchSubscriber() {
        $searchText
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                Task {
                    await self?.searchLocations(for: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    func searchLocations(for query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            isLoading = false
            return
        }

        isLoading = true

        let urlString = "https://api.weatherapi.com/v1/search.json?key=\(apiKey)&q=\(query)"

        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([LocationSearchResult].self, from: data)
            
            searchResults = decodedData
            isLoading = false

            for location in searchResults {
                if cachedWeather[location.id] == nil {
                    await fetchWeather(for: location)
                }
            }
        } catch {
            print("Error searching locations: \(error)")
            isLoading = false
        }
    }
    
    func fetchWeather(for location: LocationSearchResult) async {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(location.name)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(WeatherModel.self, from: data)
            cachedWeather[location.id] = decodedData
        } catch {
            print("Error fetching weather data: \(error)")
        }
    }
    
    func selectLocation(_ location: LocationSearchResult) {
        if let weather = cachedWeather[location.id] {
            selectedWeather = weather
            saveLocation(location)
        }
    }
    
    private func saveLocation(_ location: LocationSearchResult) {
        do {
            let encodedData = try JSONEncoder().encode(location)
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print("Error saving location: \(error)")
        }
    }
    
    private func loadSavedLocation() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            let savedLocation = try JSONDecoder().decode(LocationSearchResult.self, from: data)
            Task {
                await fetchWeather(for: savedLocation)
                if let weather = cachedWeather[savedLocation.id] {
                    selectedWeather = weather
                }
            }
        } catch {
            print("Error loading saved location: \(error)")
        }
    }
    
    func resetSearch() {
        searchResults = []
        selectedWeather = nil
    }
    // for testing
    /*
    func clearDefaults() {
           // Clear saved location
           UserDefaults.standard.removeObject(forKey: userDefaultsKey)
           
           // Reset the view model state
           resetSearch()
           searchText = ""
       }
     */
}


