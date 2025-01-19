import SwiftUI

struct StartButtonsView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var showEnterLocationSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 1) Enter location
            Button(action: {
                showEnterLocationSheet = true
            }) {
                Text("Enter your location")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showEnterLocationSheet) {
                EnterLocationSheetView()
                    .environmentObject(locationManager)
            }
            
            // 2) Autolocate
            Button(action: {
                locationManager.setRegionToWroclaw()
            }) {
                Text("Autolocate")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // 3) "Get Stats"
            NavigationLink(destination: LocationDataView()) {
                Text("Get Stats")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding([.leading, .trailing], 40)
    }
}

struct StartButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        StartButtonsView()
            .environmentObject(LocationManager())
    }
}
