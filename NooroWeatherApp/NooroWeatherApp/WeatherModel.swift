//
//  WeatherModel.swift
//  NooroWeatherApp
//
//  Created by Weng Seong Cheang on 12/7/24.
//

// MARK: - WeatherModel
struct WeatherModel: Codable {
    let location: Location
    let current: Current
}

// MARK: - Current
struct Current: Codable {
    let tempF: Double
    let condition: Condition
    let humidity: Int
    let feelslikeF, uv: Double

    enum CodingKeys: String, CodingKey {
        case tempF = "temp_f"
        case condition, humidity
        case feelslikeF = "feelslike_f"
        case uv
    }
}

// MARK: - Condition
struct Condition: Codable {
    let text, icon: String
}

// MARK: - Location
struct Location: Codable {
    let name, region, country: String
    let lat, lon: Double
    let tzID: String
    let localtimeEpoch: Int
    let localtime: String

    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case tzID = "tz_id"
        case localtimeEpoch = "localtime_epoch"
        case localtime
    }
}


// MARK: - Location Search Result Model
struct LocationSearchResult: Codable, Identifiable {
    let id: Int
    let name, region, country: String
    let lat, lon: Double
    let url: String
}
