// LocationManager.swift

import Foundation
import Combine
import MapKit

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

class LocationManager: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var userLocation: IdentifiableLocation?

    init() {
        // Ustawienie domyślnego regionu na Warszawę z odpowiednim zakresem dla przybliżenia na miasto
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122), // Warszawa
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Średni zakres
        )
    }

    func setRegionToWroclaw() {
        let wroclawCoordinate = CLLocationCoordinate2D(latitude: 51.1079, longitude: 17.0385)
        self.region = MKCoordinateRegion(
            center: wroclawCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Średni zakres
        )
        self.userLocation = IdentifiableLocation(coordinate: wroclawCoordinate)
    }
    
    // Opcjonalnie: Funkcja do resetowania lokalizacji na Warszawę
    func setRegionToWarsaw() {
        let warsawCoordinate = CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122)
        self.region = MKCoordinateRegion(
            center: warsawCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        self.userLocation = nil // Usunięcie lokalizacji użytkownika
    }
}
