// StartButtonsView.swift

import SwiftUI

struct StartButtonsView: View {
    @EnvironmentObject var locationManager: LocationManager // Dostęp do LocationManager

    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                // Akcja dla "Enter your location" (Możesz dodać funkcjonalność według potrzeb)
            }) {
                Text("Enter your location")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                // Ustawienie regionu na Wrocław
                locationManager.setRegionToWroclaw()
            }) {
                Text("Autolocate")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

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
            .environmentObject(LocationManager()) // Przekazanie LocationManager do podglądu
    }
}
