import SwiftUI

struct AuthGateView: View {
    @StateObject private var authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel = .shared) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                RootTabView(authViewModel: authViewModel, onSignedOut: {
                    authViewModel.email = ""
                    authViewModel.password = ""
                })
            } else {
                NavigationStack {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)

                        VStack(spacing: 12) {
                            Text("EchoLingo")
                                .font(.largeTitle.weight(.bold))
                            Text("Live captions and real-time translation for work and study.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 14) {
                            NavigationLink {
                                SignInView(authViewModel: authViewModel)
                            } label: {
                                Text("Sign In")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }

                            NavigationLink {
                                SignUpView(authViewModel: authViewModel)
                            } label: {
                                Text("Create Account")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }

                            NavigationLink {
                                RootTabView(authViewModel: authViewModel)
                            } label: {
                                Text("Continue as Guest")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }

                        if let successMessage = authViewModel.successMessage {
                            Text(successMessage)
                                .font(.footnote)
                                .foregroundStyle(.green)
                                .multilineTextAlignment(.center)
                        }

                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()
                    }
                    .padding(24)
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                    .onOpenURL { url in
                        authViewModel.handleIncomingURL(url)
                    }
                }
            }
        }
    }
}

#Preview {
    AuthGateView()
}
