import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var airQualityService: AirQualityService
    
    @State private var selectedStationId: Int? = nil
    @State private var navigateToDetails = false
    
    var body: some View {
        ZStack {
            // Usuwamy NavigationView i pozostawiamy sam Map + ukryty NavigationLink
            Map(
                coordinateRegion: $locationManager.region,
                interactionModes: .all,
                showsUserLocation: false,
                annotationItems: combinedAnnotations
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    if let station = item.station {
                        StationCircleView(
                            stationId: station.id,
                            onDetails: { stId in
                                selectedStationId = stId
                                navigateToDetails = true
                            }
                        )
                        .environmentObject(airQualityService)
                        
                    } else if let _ = item.userLocation {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    } else {
                        EmptyView()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Ukryty NavigationLink do LocationDataView (GetStats)
            NavigationLink(
                destination: LocationDataView(selectedStationId: selectedStationId)
                    .environmentObject(airQualityService)
                    .environmentObject(locationManager),
                isActive: $navigateToDetails
            ) {
                EmptyView()
            }
        }
        // Brak drugiej nawigacji => będzie tylko 1 strzałka w stacku,
        // zarządzanym np. przez ContentView lub inny rodzic.
    }
    
    private var combinedAnnotations: [CustomAnnotation] {
        var result: [CustomAnnotation] = []
        
        if let user = locationManager.userLocation {
            result.append(
                CustomAnnotation(
                    coordinate: user.coordinate,
                    station: nil,
                    userLocation: user
                )
            )
        }
        
        let stationAnnots = airQualityService.stations.compactMap { st -> CustomAnnotation? in
            guard let lat = Double(st.gegrLat),
                  let lon = Double(st.gegrLon) else {
                return nil
            }
            return CustomAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                station: st,
                userLocation: nil
            )
        }
        result.append(contentsOf: stationAnnots)
        return result
    }
}
