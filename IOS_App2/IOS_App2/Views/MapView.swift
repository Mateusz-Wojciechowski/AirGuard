import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var airQualityService: AirQualityService
    
    var body: some View {
        Map(
            coordinateRegion: $locationManager.region,
            interactionModes: .all,
            showsUserLocation: false,
            annotationItems: combinedAnnotations
        ) { item in
            MapAnnotation(coordinate: item.coordinate) {
                if let station = item.station {
                    StationCircleView(stationId: station.id)
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LocationManager())
            .environmentObject(AirQualityService())
    }
}
