import Foundation

/// Robimy z tego klasę (Reference Type),
/// aby modyfikacje tej stacji w słowniku od razu były widoczne w widokach, które jej używają.
class AirQualityStation: Codable, Identifiable {
    let id: Int
    let stationName: String
    let gegrLat: String
    let gegrLon: String
    let city: City
    let addressStreet: String?
    
    // Pola na szczegółowe dane (domyślnie nil)
    var overallIndexName: String? = nil
    var pm10IndexName: String? = nil
    var pm25IndexName: String? = nil
    
    var pm10: Double? = nil
    var pm25: Double? = nil
    
    init(id: Int,
         stationName: String,
         gegrLat: String,
         gegrLon: String,
         city: City,
         addressStreet: String?) {
        
        self.id = id
        self.stationName = stationName
        self.gegrLat = gegrLat
        self.gegrLon = gegrLon
        self.city = city
        self.addressStreet = addressStreet
    }
    
    // MARK: - Dekodowanie JSON
    required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let id = try c.decode(Int.self, forKey: .id)
        let stationName = try c.decode(String.self, forKey: .stationName)
        let gegrLat = try c.decode(String.self, forKey: .gegrLat)
        let gegrLon = try c.decode(String.self, forKey: .gegrLon)
        let city = try c.decode(City.self, forKey: .city)
        let addressStreet = try? c.decode(String?.self, forKey: .addressStreet)
        
        self.init(id: id,
                  stationName: stationName,
                  gegrLat: gegrLat,
                  gegrLon: gegrLon,
                  city: city,
                  addressStreet: addressStreet)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, stationName, gegrLat, gegrLon, city, addressStreet
    }
    
    // MARK: - City i Commune
    class City: Codable {
        let id: Int
        let name: String
        let commune: Commune
        
        init(id: Int, name: String, commune: Commune) {
            self.id = id
            self.name = name
            self.commune = commune
        }
        
        class Commune: Codable {
            let communeName: String
            let districtName: String
            let provinceName: String
        }
    }
}
