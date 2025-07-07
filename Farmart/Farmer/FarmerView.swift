import SwiftUI

struct FarmerView: View {
    var body: some View {
        VStack {
            Text("Farmer Screen")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Farmer")
    }
}

struct FarmerView_Previews: PreviewProvider {
    static var previews: some View {
        FarmerView()
    }
} 