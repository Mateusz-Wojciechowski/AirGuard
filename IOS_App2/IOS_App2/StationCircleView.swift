import SwiftUI

struct StationCircleView: View {
    @EnvironmentObject var airQualityService: AirQualityService
    
    let stationId: Int
    let onDetails: ((Int) -> Void)? // callback, np. by przejść do "GetStats"
    
    @State private var isLoading = false
    @State private var showInfo = false
    
    private var station: AirQualityStation? {
        airQualityService.stationById[stationId]
    }
    
    var body: some View {
        Circle()
            .fill(colorForStation(station))
            .frame(width: 20, height: 20)
            .overlay(
                isLoading ?
                    AnyView(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.6)
                    ) : AnyView(EmptyView())
            )
            .onTapGesture {
                isLoading = true
                airQualityService.fetchDetails(for: stationId) {
                    DispatchQueue.main.async {
                        isLoading = false
                        showInfo = true
                    }
                }
            }
            .popover(isPresented: $showInfo) {
                if let st = station {
                    VStack(spacing: 8) {
                        Text(st.stationName)
                            .font(.headline)
                        Text("Ogólny indeks: \(st.overallIndexName ?? "Brak")")
                        Text("PM10: \(formatPM(st.pm10)), idx: \(st.pm10IndexName ?? "Brak")")
                        Text("PM2.5: \(formatPM(st.pm25)), idx: \(st.pm25IndexName ?? "Brak")")
                        
                        Divider().padding(.vertical, 8)
                        
                        // Przycisk "Details"
                        Button("Details") {
                            showInfo = false
                            onDetails?(stationId)
                        }
                    }
                    .padding()
                } else {
                    Text("Brak danych stacji.")
                        .padding()
                }
            }
    }
    
    private func colorForStation(_ station: AirQualityStation?) -> Color {
        guard let st = station,
              let idxName = st.overallIndexName else {
            return .gray
        }
        switch idxName.lowercased() {
        case "bardzo dobry": return .green
        case "dobry":        return .green
        case "umiarkowany":  return .yellow
        case "dostateczny":  return .orange
        case "zły":          return .red
        case "bardzo zły":   return .purple
        default:             return .gray
        }
    }
    
    private func formatPM(_ val: Double?) -> String {
        guard let v = val else { return "-" }
        return String(format: "%.1f", v)
    }
}
