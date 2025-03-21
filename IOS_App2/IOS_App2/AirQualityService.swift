import Foundation
import Combine
import MapKit

class AirQualityService: ObservableObject {
    
    @Published var stations: [AirQualityStation] = []
    @Published var stationById: [Int: AirQualityStation] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://api.gios.gov.pl/pjp-api/rest"
    
    func fetchStations() {
        guard let url = URL(string: "\(baseURL)/station/findAll") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [AirQualityStation].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Pobrano listę stacji (bez detali).")
                case .failure(let error):
                    print("Błąd stacji: \(error)")
                }
            } receiveValue: { [weak self] downloaded in
                guard let self = self else { return }
                
                self.stations = downloaded
                
                var dict: [Int: AirQualityStation] = [:]
                for st in downloaded {
                    dict[st.id] = st
                }
                self.stationById = dict
            }
            .store(in: &cancellables)
    }
    
    func fetchDetails(for stationId: Int, completion: @escaping () -> Void = {}) {
        fetchIndex(for: stationId) { [weak self] indexResp in
            self?.fetchSensors(for: stationId) { sensors in
                self?.updateStation(stationId, indexResp: indexResp, sensors: sensors) {
                    completion()
                }
            }
        }
    }
    
    private func updateStation(_ stationId: Int,
                               indexResp: AirQualityIndexResponse?,
                               sensors: [Sensor]?,
                               done: @escaping ()->Void)
    {
        DispatchQueue.main.async {
            guard let st = self.stationById[stationId] else {
                done()
                return
            }
            
            if let indexResp = indexResp {
                st.overallIndexName = indexResp.stIndexLevel?.indexLevelName
                st.pm10IndexName = indexResp.pm10IndexLevel?.indexLevelName
                st.pm25IndexName = indexResp.pm25IndexLevel?.indexLevelName
            }
            
            guard let sensors = sensors else {
                done()
                return
            }
            
            self.fetchPM10andPM25(st, sensors: sensors) {
                done()
            }
        }
    }
    
    private func fetchPM10andPM25(_ st: AirQualityStation,
                                  sensors: [Sensor],
                                  completion: @escaping ()->Void)
    {
        let pm10Sensor = sensors.first(where: { $0.param.paramFormula == "PM10" })
        let pm25Sensor = sensors.first(where: { $0.param.paramFormula == "PM2.5" })
        
        let group = DispatchGroup()
        
        if let pm10Sensor = pm10Sensor {
            group.enter()
            fetchSensorData(sensorId: pm10Sensor.id) { val in
                DispatchQueue.main.async {
                    st.pm10 = val
                    group.leave()
                }
            }
        }
        if let pm25Sensor = pm25Sensor {
            group.enter()
            fetchSensorData(sensorId: pm25Sensor.id) { val in
                DispatchQueue.main.async {
                    st.pm25 = val
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    // MARK: - Index
    func fetchIndex(for stationId: Int, completion: @escaping (AirQualityIndexResponse?) -> Void) {
        guard let url = URL(string: "\(baseURL)/aqindex/getIndex/\(stationId)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, resp) -> Data in
                guard let http = resp as? HTTPURLResponse,
                      http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AirQualityIndexResponse.self, decoder: JSONDecoder())
            .map { Optional($0) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { resp in
                completion(resp)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sensors
    func fetchSensors(for stationId: Int, completion: @escaping ([Sensor]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/station/sensors/\(stationId)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, resp) -> Data in
                guard let http = resp as? HTTPURLResponse,
                      http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Sensor].self, decoder: JSONDecoder())
            .map { Optional($0) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { sensors in
                completion(sensors)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - fetchSensorData - zwraca TYLKO pierwszy nie-nil value
    private func fetchSensorData(sensorId: Int, completion: @escaping (Double?) -> Void) {
        guard let url = URL(string: "\(baseURL)/data/getData/\(sensorId)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, resp) -> Data in
                guard let http = resp as? HTTPURLResponse,
                      http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: SensorDataResponse.self, decoder: JSONDecoder())
            .map { Optional($0) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { sensorData in
                guard let sData = sensorData else {
                    completion(nil)
                    return
                }
                let value = sData.values.first(where: { $0.value != nil })?.value
                completion(value)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Nowa metoda: pobiera CAŁĄ historię wartości
    func fetchSensorDataHistory(sensorId: Int, completion: @escaping ([ValueItem]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/data/getData/\(sensorId)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, resp) -> Data in
                guard let http = resp as? HTTPURLResponse,
                      http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: SensorDataResponse.self, decoder: JSONDecoder())
            .map { Optional($0) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { sensorData in
                guard let sData = sensorData else {
                    completion(nil)
                    return
                }
                // Zwracamy wszystkie ValueItem (np. ~24h)
                completion(sData.values)
            }
            .store(in: &cancellables)
    }
}
