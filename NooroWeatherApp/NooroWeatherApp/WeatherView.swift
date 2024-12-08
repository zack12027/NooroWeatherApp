//
//  ContentView.swift
//  NooroWeatherApp
//
//  Created by Weng Seong Cheang on 12/7/24.
//

import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        VStack {
            // Search Bar
            HStack {
                TextField("Search Location", text: Binding(
                    get: { viewModel.searchText },
                    set: { newValue in
                        viewModel.searchText = newValue
                        if !newValue.isEmpty {
                            viewModel.resetSearch() // Clear previously selected weather when typing
                        }
                    }
                ))
                .padding(.vertical, 8)
                .padding(.leading, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                    }
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            if let weather = viewModel.selectedWeather {
                // Show Weather Details
                WeatherDetailsView(weather: weather)
                    .padding(.top, 20)
                    .frame(maxHeight: .infinity, alignment: .top)
            } else if viewModel.searchResults.isEmpty && viewModel.searchText.isEmpty {
                // Empty State
                Text("No City Selected")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Please Search for a city")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                ProgressView("Searching...")
                    .padding(.top, 16)
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                // Search Results List
                ScrollView
                {
                    LazyVStack {
                        ForEach(viewModel.searchResults) { location in
                            if let weather = viewModel.cachedWeather[location.id] {
                                Button(action: {
                                    viewModel.selectLocation(location)
                                }) {
                                    LocationCard(location: location, weather: weather)
                                }
                            } else {
                                ProgressView()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 8)
            }
        }
        .padding()
        
        // for testing
        /*
        Button(action: {
                        viewModel.clearDefaults()
                    }) {
                        Text("Clear Defaults")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 16)
         */
    }
}

struct LocationCard: View {
    let location: LocationSearchResult
    let weather: WeatherModel

    var body: some View {
        HStack {
            // City Info
            VStack(alignment: .leading) {
                
                Text(location.name)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                    
                
                HStack
                {
                    Text("\(weather.current.tempF, specifier: "%.0f")")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                    Text("°")
                        .foregroundColor(.primary)
                        .baselineOffset(15)
                }
                
            }
            .padding()

            Spacer()

            // Weather Info
            if let iconURL = URL(string: "https:\(weather.current.condition.icon)") {
                AsyncImage(url: iconURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                }
            }

        }
        .padding()
        .background(Color(#colorLiteral(red: 0.9490196109, green: 0.9490196109, blue: 0.9490196109, alpha: 1)))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}


#Preview {
    WeatherView()
        .environmentObject(WeatherViewModel())
}

struct WeatherDetailsView: View {
    let weather: WeatherModel

    var body: some View {
        VStack(spacing: 10) {
            
            if let url = URL(string: "https:\(weather.current.condition.icon)") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } placeholder: {
                    ProgressView()
                }
            }
            
            HStack
            {
                Text(weather.location.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
            }
            // Temperature
            HStack(alignment: .top, spacing: 0){
                Text("\(weather.current.tempF, specifier: "%.0f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("°")
                    .foregroundColor(.primary)
                    .baselineOffset(15)
            }
           
            
            HStack
            {
                VStack
                {
                    Text("Humidity")
                        .foregroundColor(Color(#colorLiteral(red: 0.7686274648, green: 0.7686274648, blue: 0.7686274648, alpha: 1)))
                    Text("\(weather.current.humidity)%")
                        .foregroundColor(Color(#colorLiteral(red: 0.6039215326, green: 0.603921473, blue: 0.603921473, alpha: 1)))
                }
                .padding()
                Spacer()
                VStack
                {
                    Text("UV")
                        .foregroundColor(Color(#colorLiteral(red: 0.7686274648, green: 0.7686274648, blue: 0.7686274648, alpha: 1)))
                    Text("\(weather.current.uv, specifier: "%.0f")")
                        .foregroundColor(Color(#colorLiteral(red: 0.6039215326, green: 0.603921473, blue: 0.603921473, alpha: 1)))
                }
                .padding()
                Spacer()
                VStack
                {
                    Text("Feels Like")
                        .foregroundColor(Color(#colorLiteral(red: 0.7686274648, green: 0.7686274648, blue: 0.7686274648, alpha: 1)))
                    Text("\(weather.current.feelslikeF, specifier: "%.0f")°")
                        .foregroundColor(Color(#colorLiteral(red: 0.6039215326, green: 0.603921473, blue: 0.603921473, alpha: 1)))
                }
                .padding()
                
            }
            .background(Color(#colorLiteral(red: 0.9490196109, green: 0.9490196109, blue: 0.9490196109, alpha: 1)))
            .cornerRadius(20)
            
        }
        .padding()
    }
}



#Preview {
    LocationCard(
        location: LocationSearchResult(
            id: 2801268,
            name: "London",
            region: "City of London, Greater London",
            country: "United Kingdom",
            lat: 51.52,
            lon: -0.11,
            url: "london-city-of-london-greater-london-united-kingdom"
        ),
        weather: WeatherModel(
            location: Location(
                name: "London",
                region: "City of London, Greater London",
                country: "United Kingdom",
                lat: 51.52,
                lon: -0.11,
                tzID: "Europe/London",
                localtimeEpoch: 1733611615,
                localtime: "2024-12-07 22:46"
            ),
            current: Current(
                tempF: 45.3,
                condition: Condition(
                    text: "Overcast",
                    icon: "//cdn.weatherapi.com/weather/64x64/night/122.png"
                ), humidity: 89,
                feelslikeF: 76,
                uv: 0
            )
        )
    )
}

#Preview {
    WeatherDetailsView(
        weather: WeatherModel(
            location: Location(
                name: "London",
                region: "City of London, Greater London",
                country: "United Kingdom",
                lat: 51.5171,
                lon: -0.1062,
                tzID: "Europe/London",
                localtimeEpoch: 1733611615,
                localtime: "2024-12-07 22:46"
            ),
            current: Current(
                tempF: 45.3,
                condition: Condition(
                    text: "Overcast",
                    icon: "//cdn.weatherapi.com/weather/64x64/night/122.png"
                ),
                humidity: 40,
                feelslikeF: 76,
                uv: 0
            )
        )
    )
}
