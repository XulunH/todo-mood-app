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
                TabView {
                    TodoListView(authManager: authManager)
                        .tabItem {
                            Image(systemName: "checklist")
                            Text("Todos")
                        }
                    MoodView(authManager: authManager)
                        .tabItem {
                            Image(systemName: "face.smiling")
                            Text("Mood")
                        }
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(authManager)
    }
}
