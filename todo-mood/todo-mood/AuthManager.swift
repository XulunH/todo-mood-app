//
//  AuthManager.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/16/25.
//

import Foundation

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    private var authToken: String?
    
    func register(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userData = UserCreate(email: email, password: password)
            let jsonData = try JSONEncoder().encode(userData)
            
            let user: User = try await networkService.fetch("/register", method: "POST", body: jsonData)
            
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loginData = "username=\(email)&password=\(password)"
            let formData = loginData.data(using: .utf8)!
            
            let token: Token = try await networkService.fetch("/login", method: "POST", body: formData, contentType: "application/x-www-form-urlencoded")
            
            // Store the token
            authToken = token.access_token
            
            // Fetch user info
            await fetchCurrentUser()
            
            // Set authenticated to true
            isAuthenticated = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func fetchCurrentUser() async {
        do {
            let user: User = try await networkService.fetchWithAuth("/me", token: authToken ?? "")
            currentUser = user
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        authToken = nil
    }
    
    func getAuthToken() -> String? {
        return authToken
    }
}
