//
//  NooroWeatherAppApp.swift
//  NooroWeatherApp
//
//  Created by Weng Seong Cheang on 12/7/24.
//

import SwiftUI

@main
struct NooroWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherView()
                .environmentObject(
                    WeatherViewModel(
                        weatherService: WeatherAPIService(),
                        locationService: UserDefaultsLocationService()
                    )
                )
        }
    }
}
