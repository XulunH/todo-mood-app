//
//  ContentView.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TodoListView(authManager: authManager)
            } else {
                LoginView()
            }
        }
        .environmentObject(authManager)
    }
}
