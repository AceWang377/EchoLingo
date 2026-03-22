import SwiftUI

struct AuthGateView: View {
    @StateObject private var authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel = .shared) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(minLength: 20)

                Image("EchoLingoLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                VStack(spacing: 8) {
                    Text("Sign in to unlock real translation later")
                        .font(.title3.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text("You can continue as a guest now. Login will later be used for usage limits, sync, and protecting your translation API cost.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    TextField("Email", text: $authViewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    SecureField("Password", text: $authViewModel.password)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

                Text("Signup emails should now use echolingo://auth/callback. In Supabase, keep Site URL as a real public URL and add echolingo://auth/callback to Redirect URLs.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    Button {
                        Task { await authViewModel.signIn() }
                    } label: {
                        Text(authViewModel.isLoading ? "Signing In..." : "Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(authViewModel.isLoading)

                    Button {
                        Task { await authViewModel.signUp() }
                    } label: {
                        Text(authViewModel.isLoading ? "Creating Account..." : "Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(authViewModel.isLoading)

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

                Spacer()
            }
            .padding(20)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationDestination(isPresented: .constant(authViewModel.isSignedIn)) {
                RootTabView(authViewModel: authViewModel, onSignedOut: {
                    authViewModel.email = ""
                    authViewModel.password = ""
                })
            }
            .onOpenURL { url in
                authViewModel.handleIncomingURL(url)
            }
        }
    }
}

#Preview {
    AuthGateView()
}
