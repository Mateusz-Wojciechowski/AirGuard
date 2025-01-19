import SwiftUI

@main
struct IOS_App2App: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var airQualityService = AirQualityService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(airQualityService)
        }
    }
}
