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
                .padding(.vertical, 12)
                .padding(.leading, 10)
                .background(Color(.systemGray6))
                .cornerRadius(16)
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
                    .font(.custom("Poppins-SemiBold", size: 30))
                
                Text("Please Search for a city")
                    .font(.custom("Poppins-SemiBold", size: 15))
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
        
        //Testing purpose
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
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(.primary)
                    
                
                HStack(alignment: .top, spacing: 0)
                {
                    Text("\(weather.current.tempF, specifier: "%.0f")")
                        .font(.custom("Poppins-Medium", size: 60))
                        .foregroundColor(.primary)
                    Text("°")
                        .foregroundColor(.primary)
                        .offset(y:10)
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
        .padding(.horizontal)
        .background(Color(#colorLiteral(red: 0.9490196109, green: 0.9490196109, blue: 0.9490196109, alpha: 1)))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}


#Preview {
    WeatherView()
        .environmentObject(
                    WeatherViewModel(
                        weatherService: WeatherAPIService(),
                        locationService: UserDefaultsLocationService()
                    )
                )
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
                        .frame(width: 123, height: 123)
                } placeholder: {
                    ProgressView()
                }
            }
            
            HStack
            {
                Text(weather.location.name)
                    .font(.custom("Poppins-SemiBold", size: 30))
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 21, height: 21)
                
            }
            // Temperature
            HStack(alignment: .top, spacing: 0){
                Text("\(weather.current.tempF, specifier: "%.0f")")
                    .font(.custom("Poppins-Medium", size: 70))
                    .padding(.bottom)
                
                Text("°")
                    .foregroundColor(.primary)
                    .offset(y: 10)
            }
           
            
            HStack
            {
                VStack
                {
                    DisplayData(title: "Humidity", value: "\(weather.current.humidity)%")
                }
                .padding()
                
                Spacer()
                VStack
                {
                    DisplayData(title: "UV", value: String(format: "%.0f", weather.current.uv))
                }
                .padding()
                Spacer()
                VStack
                {
                    DisplayData(title: "Feels Like", value: String(format: "%.0f", weather.current.feelslikeF))
                }
                .padding()
                
            }
            .background(Color(#colorLiteral(red: 0.9490196109, green: 0.9490196109, blue: 0.9490196109, alpha: 1)))
            .cornerRadius(16)
            .padding()
            
        }
        .padding()
    }
}

struct DisplayData:View
{
    let title:String
    let value:String
    var body: some View
    {
        Text(title)
            .font(.custom("Poppins-Medium", size: 12))
            .foregroundColor(Color(#colorLiteral(red: 0.7686274648, green: 0.7686274648, blue: 0.7686274648, alpha: 1)))
        Text(value)
            .font(.custom("Poppins-Medium", size: 15))
            .foregroundColor(Color(#colorLiteral(red: 0.6039215326, green: 0.603921473, blue: 0.603921473, alpha: 1)))
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
