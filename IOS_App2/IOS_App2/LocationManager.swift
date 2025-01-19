import Foundation
import Combine
import MapKit
import CoreLocation

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

class LocationManager: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var userLocation: IdentifiableLocation?
    
    private let geocoder = CLGeocoder()
    
    init() {
        // Ustawienie domyślnego regionu na Warszawę
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    func setRegionToWroclaw() {
        let wroclawCoordinate = CLLocationCoordinate2D(latitude: 51.1079, longitude: 17.0385)
        self.region = MKCoordinateRegion(
            center: wroclawCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        self.userLocation = IdentifiableLocation(coordinate: wroclawCoordinate)
    }
    
    func setRegionToWarsaw() {
        let warsawCoordinate = CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122)
        self.region = MKCoordinateRegion(
            center: warsawCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        self.userLocation = nil
    }
    
    /// Nowa metoda: geokodujemy wpisany adres i ustawiamy region oraz userLocation
    func geocodeAndSetRegion(address: String, completion: @escaping (Bool) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let err = error {
                print("Geocoding error: \(err)")
                completion(false)
                return
            }
            guard let placemark = placemarks?.first,
                  let coord = placemark.location?.coordinate else {
                completion(false)
                return
            }
            DispatchQueue.main.async {
                self.region = MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                self.userLocation = IdentifiableLocation(coordinate: coord)
                completion(true)
            }
        }
    }
}
