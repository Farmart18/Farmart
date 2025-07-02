import SwiftUI

enum OnboardingRoute: Hashable {
    case consumer
    case farmer
}

struct OnboardingView: View {
    @State private var selection: OnboardingRoute?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                // MARKS:-  Consumer
                VStack(spacing: 24) {
                    Button(action: {
                        selection = .consumer
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .foregroundColor(Color.ButtonColor)
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(.systemGray3))
                            Text("Consumer")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 60)
                .padding(.bottom, 16)
                
                // MARKS:-  Divider and 'Or continue as'
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 40)
                    Text("Or continue as")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 16)
                // MARKS:-  Farmer'
                VStack(spacing: 24) {
                    Text("Are you a Farmer?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    Text("Continue as a farmer to Uplaod your Batches.")
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 34)
                    Button(action: {
                        selection = .farmer
                    }) {
                        Text("Continue as Farmer")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.ButtonColor)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 40)
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .padding(.top, 0)
                Spacer(minLength: 0)
            }
            .background(Color.Background.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(item: $selection) { route in
                switch route {
                case .consumer:
                    ConsumerView()
                case .farmer:
                    FarmerView()
                }
            }
        }
    }
}


