import SwiftUI

struct ConsumerView: View {
    var body: some View {
        VStack {
            Text("Consumer Screen")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Consumer")
    }
}

struct ConsumerView_Previews: PreviewProvider {
    static var previews: some View {
        ConsumerView()
    }
} 