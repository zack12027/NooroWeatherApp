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
    @Published var isLoading = false

    private let weatherService: WeatherService
    private let locationService: LocationPersistenceService
    private var cancellables = Set<AnyCancellable>()
    
    convenience init() {
        self.init(
            weatherService: WeatherAPIService(),
            locationService: UserDefaultsLocationService()
        )
    }

    init(weatherService: WeatherService, locationService: LocationPersistenceService) {
        self.weatherService = weatherService
        self.locationService = locationService
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

        do {
            searchResults = try await weatherService.searchLocations(for: query)
            isLoading = false

            for location in searchResults where cachedWeather[location.id] == nil {
                let weather = try await weatherService.fetchWeather(for: location)
                cachedWeather[location.id] = weather
            }
        } catch {
            print("Error searching locations: \(error)")
            isLoading = false
        }
    }

    func selectLocation(_ location: LocationSearchResult) {
        if let weather = cachedWeather[location.id] {
            selectedWeather = weather
            locationService.saveLocation(location)
        }
    }

    private func loadSavedLocation() {
        guard let savedLocation = locationService.loadSavedLocation() else { return }
        Task {
            do {
                let weather = try await weatherService.fetchWeather(for: savedLocation)
                cachedWeather[savedLocation.id] = weather
                selectedWeather = weather
            } catch {
                print("Error loading saved location: \(error)")
            }
        }
    }

    func resetSearch() {
        searchResults = []
        selectedWeather = nil
    }
    //Testing purposes
    /*
    func clearDefaults() {
        locationService.clearDefaults()
        resetSearch()
        searchText = ""
    }
     */
}
