import SwiftUI

struct SignInView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 18) {
            Image("EchoLingoLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 8) {
                Text("Sign In")
                    .font(.title2.weight(.bold))
                Text("Welcome back to EchoLingo")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

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
        }
    }
}

#Preview {
    SignInView(authViewModel: .shared)
}
