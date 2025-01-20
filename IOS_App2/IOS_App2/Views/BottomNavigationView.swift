// BottomNavigationView.swift

import SwiftUI

struct BottomNavigationView: View {
    @EnvironmentObject var locationManager: LocationManager // Dostęp do LocationManager
    @State private var navigateToMap = false // Stan nawigacji do MapView

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                
            }) {
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }

            Spacer()

            Button(action: {
                // Akcja dla ikony Mapy
                navigateToMap = true
            }) {
                Image(systemName: "map.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }

            // NavigationLink do MapView
            NavigationLink(destination: MapView(), isActive: $navigateToMap) {
                EmptyView()
            }

            Spacer()

            Button(action: {
                
            }) {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
    }
}

struct BottomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationView()
            .environmentObject(LocationManager()) // Przekazanie LocationManager do podglądu
    }
}
