import MapKit

/// Każda adnotacja ma własny unikalny `id = UUID()`,
/// aby SwiftUI nie re-używało tych samych widoków do różnych stacji.
struct CustomAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    // Stacja z tablicy "stations" (podstawowe info),
    // ale właściwe parametry PM i index będą w stationById w serwisie.
    let station: AirQualityStation?
    
    // Lokalizacja usera, jeśli to adnotacja usera
    let userLocation: IdentifiableLocation?
}
