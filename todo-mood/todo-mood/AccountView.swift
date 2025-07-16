import SwiftUI

struct AccountView: View {
    @ObservedObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // User info section
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    if let user = authManager.currentUser {
                        Text(user.email)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 40)

                Spacer()

                // Logout button
                Button(action: {
                    authManager.logout()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Logout")
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Account")
        }
    }
}
