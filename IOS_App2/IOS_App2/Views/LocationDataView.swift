import SwiftUI
import MapKit

struct LocationDataView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var airQualityService: AirQualityService
    
    @State private var showPM10Info = false
    @State private var showPM25Info = false
    
    @State private var navigateToMap = false
    
    // Dodajemy nawigację do widoku wykresów
    @State private var showPlots = false
    @State private var plotsStationId: Int? = nil
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.93, blue: 1.0),
                    Color(red: 0.75, green: 0.85, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Text("Location Data")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 16)
                    
                    // Kafelek z AQI
                    VStack(spacing: 8) {
                        let indexName = nearestStationIndex()
                        Image(systemName: emojiForIndex(indexName))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(colorForIndex(indexName))
                        
                        if let userLocation = locationManager.userLocation {
                            Text("\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let nearBasic = nearestStation() {
                                if let nearFull = airQualityService.stationById[nearBasic.id] {
                                    Text("AQI: \(nearFull.overallIndexName ?? "-")")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("AQI: -")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            } else {
                                Text("AQI: -")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        } else {
                            Text("AQI: -")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        // Przycisk do wykresów
                        Button(action: {
                            if let st = nearestStation() {
                                plotsStationId = st.id
                                showPlots = true
                            }
                        }) {
                            Text("Plots for this location")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                    )
                    .shadow(radius: 4)
                    .padding(.horizontal, 16)
                    
                    // "More details"
                    VStack(alignment: .leading, spacing: 8) {
                        Text("More details")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        let nearBasic = nearestStation()
                        if let nb = nearBasic, let nf = airQualityService.stationById[nb.id] {
                            HStack(alignment: .center, spacing: 20) {
                                // PM10
                                Button {
                                    showPM10Info = true
                                } label: {
                                    VStack {
                                        Text("PM10")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("\(formatPM(nf.pm10)) µg/m³")
                                            .font(.callout)
                                        Text("\(nf.pm10IndexName ?? "Brak")")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Divider()
                                    .frame(height: 40)
                                
                                // PM2.5
                                Button {
                                    showPM25Info = true
                                } label: {
                                    VStack {
                                        Text("PM2.5")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("\(formatPM(nf.pm25)) µg/m³")
                                            .font(.callout)
                                        Text("\(nf.pm25IndexName ?? "Brak")")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        } else {
                            Text("No station data available.")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                    )
                    .shadow(radius: 4)
                    .padding(.horizontal, 16)
                    
                    // "Closest stations" + mapa
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Closest stations")
                            .font(.headline)
                        
                        Map(
                            coordinateRegion: $locationManager.region,
                            interactionModes: .all,
                            showsUserLocation: false,
                            annotationItems: combinedAnnotations
                        ) { item in
                            MapAnnotation(coordinate: item.coordinate) {
                                if let st = item.station {
                                    StationCircleView(stationId: st.id)
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
                        .frame(height: 300)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                        
                        Button {
                            navigateToMap = true
                        } label: {
                            Text("View on Map")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        NavigationLink(
                            destination: MapView()
                                .environmentObject(airQualityService)
                                .environmentObject(locationManager),
                            isActive: $navigateToMap
                        ) {
                            EmptyView()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                    )
                    .shadow(radius: 4)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 40)
                }
            }
            .onAppear {
                // Pobierz dane najbliższej stacji
                if let nb = nearestStation() {
                    airQualityService.fetchDetails(for: nb.id)
                }
            }
            // Sheet do wykresów
            .sheet(isPresented: $showPlots) {
                if let sid = plotsStationId {
                    PlotsView(stationId: sid)
                        .environmentObject(airQualityService)
                }
            }
            
            // Popupy PM10 / PM2.5
            if showPM10Info {
                InfoPopupView(
                    title: "PM 10",
                    description: """
PM10 refers to particulate matter with diameter <= 10 μm ...
""",
                    onClose: { showPM10Info = false }
                )
            }
            if showPM25Info {
                InfoPopupView(
                    title: "PM 2.5",
                    description: """
PM2.5 refers to particulate matter with diameter <= 2.5 μm ...
""",
                    onClose: { showPM25Info = false }
                )
            }
        }
    }
}

// MARK: - Extension
extension LocationDataView {
    private func nearestStation() -> AirQualityStation? {
        guard let user = locationManager.userLocation else { return nil }
        return airQualityService.stations.min { s1, s2 in
            distance(s1, user.coordinate) < distance(s2, user.coordinate)
        }
    }
    
    private func nearestStationIndex() -> String? {
        guard let st = nearestStation() else { return nil }
        let full = airQualityService.stationById[st.id]
        return full?.overallIndexName
    }
    
    private func distance(_ st: AirQualityStation, _ coord: CLLocationCoordinate2D) -> Double {
        guard let lat = Double(st.gegrLat),
              let lon = Double(st.gegrLon) else {
            return Double.greatestFiniteMagnitude
        }
        let stLoc = CLLocation(latitude: lat, longitude: lon)
        let userLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return stLoc.distance(from: userLoc)
    }
    
    private func formatPM(_ value: Double?) -> String {
        guard let v = value else { return "-" }
        return String(format: "%.1f", v)
    }
    
    // Emotka do wyświetlenia
    private func emojiForIndex(_ indexName: String?) -> String {
        guard let idx = indexName?.lowercased() else {
            return "face.smiling"
        }
        switch idx {
        case "bardzo dobry": return "face.smiling"
        case "dobry":        return "face.smiling"
        case "umiarkowany":  return "face.neutral"
        case "dostateczny":  return "face.frown"
        case "zły":          return "face.frown.fill"
        case "bardzo zły":   return "face.dashed.fill"
        default:             return "face.smiling"
        }
    }
    
    private func colorForIndex(_ indexName: String?) -> Color {
        guard let idx = indexName?.lowercased() else {
            return .green
        }
        switch idx {
        case "bardzo dobry", "dobry": return .green
        case "umiarkowany":          return .yellow
        case "dostateczny":          return .orange
        case "zły":                  return .red
        case "bardzo zły":           return .purple
        default:                     return .green
        }
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
        
        let stAnnots = airQualityService.stations.compactMap { st -> CustomAnnotation? in
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
        result.append(contentsOf: stAnnots)
        return result
    }
}

// MARK: - InfoPopupView (przywrócony)
struct InfoPopupView: View {
    let title: String
    let description: String
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("OK") {
                    onClose()
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .padding(40)
        }
    }
}
