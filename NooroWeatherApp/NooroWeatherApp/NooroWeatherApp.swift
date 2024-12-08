//
//  NooroWeatherAppApp.swift
//  NooroWeatherApp
//
//  Created by Weng Seong Cheang on 12/7/24.
//

import SwiftUI

@main
struct NooroWeatherApp: App {
    @StateObject private var weatherViewModel = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            WeatherView()
                .environmentObject(weatherViewModel)
        }
    }
}
