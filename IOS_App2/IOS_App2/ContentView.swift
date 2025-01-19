import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var airQualityService: AirQualityService

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                VStack(spacing: 10) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    Text("AirGuard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                // Warunkowe wyświetlanie współrzędnych
                if let userLocation = locationManager.userLocation {
                    Text("Located, coords: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }

                Spacer()
                StartButtonsView()
                Spacer()

                BottomNavigationView()
            }
            .onAppear {
                airQualityService.fetchStations()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationManager())
            .environmentObject(AirQualityService())
    }
}
