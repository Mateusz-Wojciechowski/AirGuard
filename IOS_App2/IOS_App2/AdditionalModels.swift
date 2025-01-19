import Foundation

// MARK: - AIR QUALITY INDEX
struct AirQualityIndexResponse: Codable {
    let id: Int
    let stIndexLevel: IndexLevel?
    let stIndexCrParam: String?
    
    let pm10IndexLevel: IndexLevel?
    let pm25IndexLevel: IndexLevel?
    
    struct IndexLevel: Codable {
        let id: Int
        let indexLevelName: String
    }
}

// MARK: - SENSORS
struct Sensor: Codable {
    let id: Int
    let stationId: Int
    let param: SensorParam
}

struct SensorParam: Codable {
    let paramName: String
    let paramFormula: String
    let paramCode: String
    let idParam: Int
}

// MARK: - SENSOR DATA
struct SensorDataResponse: Codable {
    let key: String
    let values: [ValueItem]
}

struct ValueItem: Codable {
    let date: String
    let value: Double?
}
