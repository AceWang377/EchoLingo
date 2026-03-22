import SwiftUI

struct SignUpView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 18) {
            Image("EchoLingoLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title2.weight(.bold))
                Text("Create your EchoLingo account")
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

            Text("Signup emails use echolingo://auth/callback. After confirming email, come back and sign in.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

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
        }
    }
}

#Preview {
    SignUpView(authViewModel: .shared)
}
