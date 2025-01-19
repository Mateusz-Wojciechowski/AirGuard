import SwiftUI
import Charts

struct PlotsView: View {
    @EnvironmentObject var airQualityService: AirQualityService
    
    let stationId: Int
    
    @State private var pm10Data: [ValueItem] = []
    @State private var pm25Data: [ValueItem] = []
    
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if let err = errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                }
                
                if pm10Data.isEmpty && pm25Data.isEmpty {
                    Text("Loading plot data...")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("PM10 measurements")
                                .font(.headline)
                            
                            Chart(pm10Data) { item in
                                // item jest Identifiable, więc mamy .id = date
                                LineMark(
                                    x: .value("Date", item.dateAsDate),
                                    y: .value("PM10", item.value ?? 0)
                                )
                            }
                            .frame(height: 200)
                            
                            Divider()
                                .padding(.vertical, 10)
                            
                            Text("PM2.5 measurements")
                                .font(.headline)
                            
                            Chart(pm25Data) { item in
                                LineMark(
                                    x: .value("Date", item.dateAsDate),
                                    y: .value("PM2.5", item.value ?? 0)
                                )
                            }
                            .frame(height: 200)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Plots", displayMode: .inline)
            .onAppear {
                loadPlotData(for: stationId)
            }
        }
    }
    
    private func loadPlotData(for stationId: Int) {
        guard let _ = airQualityService.stationById[stationId] else {
            errorMessage = "No station found."
            return
        }
        
        // Pobieramy listę sensorów, by znaleźć sensorId dla PM10 i PM2.5
        airQualityService.fetchSensors(for: stationId) { sensors in
            guard let sensors = sensors else {
                errorMessage = "No sensors found."
                return
            }
            
            // PM10 sensor
            if let pm10Sensor = sensors.first(where: { $0.param.paramFormula == "PM10" }) {
                airQualityService.fetchSensorDataHistory(sensorId: pm10Sensor.id) { items in
                    DispatchQueue.main.async {
                        if let items = items {
                            self.pm10Data = items
                        }
                    }
                }
            }
            // PM2.5 sensor
            if let pm25Sensor = sensors.first(where: { $0.param.paramFormula == "PM2.5" }) {
                airQualityService.fetchSensorDataHistory(sensorId: pm25Sensor.id) { items in
                    DispatchQueue.main.async {
                        if let items = items {
                            self.pm25Data = items
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Dodajemy rozszerzenie "ValueItem: Identifiable"
extension ValueItem: Identifiable {
    // Jako "id" używamy daty (string) – musi być unikalny w danej tablicy
    public var id: String {
        date
    }
}

// MARK: - Pomocnicze do konwersji daty
extension ValueItem {
    var dateAsDate: Date {
        // format "2017-03-28 12:00:00"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: date) ?? Date()
    }
}
