import SwiftUI

struct EnterLocationSheetView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var addressText: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Type the location (e.g. 'Wrocław Kozia 5')")
                    .font(.headline)
                
                TextField("Location address...", text: $addressText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if let err = errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button("OK") {
                    guard !addressText.isEmpty else { return }
                    locationManager.geocodeAndSetRegion(address: addressText) { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            errorMessage = "Could not find this address."
                        }
                    }
                }
                .padding()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
                
                Spacer()
            }
            .navigationBarTitle("Enter Location", displayMode: .inline)
        }
    }
}
