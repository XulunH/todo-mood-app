//
//  TodoManager.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/16/25.
//

import Foundation

@MainActor
class TodoManager: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkService = NetworkService.shared
    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func fetchTodos() async {
        guard let token = authManager.getAuthToken() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetchedTodos: [Todo] = try await networkService.fetchWithAuth("/todos", token: token)
            todos = fetchedTodos
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addTodo(title: String, date: Date) async {
        guard let token = authManager.getAuthToken() else { return }

        let timestamp = ISO8601DateFormatter().string(from: date)
        let todoData = TodoCreate(title: title, completed: false, timestamp: timestamp)

        do {
            let jsonData = try JSONEncoder().encode(todoData)
            let newTodo: Todo = try await networkService.fetchWithAuth("/todos", token: token, method: "POST", body: jsonData)
            todos.append(newTodo)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Update completed status only (checkbox)
    func updateTodo(_ todo: Todo, completed: Bool) async {
        guard let token = authManager.getAuthToken() else { return }
        let updateData = TodoUpdate(title: nil, completed: completed, timestamp: nil)
        do {
            let jsonData = try JSONEncoder().encode(updateData)
            let updatedTodo: Todo = try await networkService.fetchWithAuth("/todos/\(todo.id)", token: token, method: "PATCH", body: jsonData)
            if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                todos[index] = updatedTodo
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Update title and/or timestamp (for edit screen)
    func updateTodo(_ todo: Todo, title: String?, date: Date?) async {
        guard let token = authManager.getAuthToken() else { return }
        let timestamp = date != nil ? ISO8601DateFormatter().string(from: date!) : nil
        let updateData = TodoUpdate(title: title, completed: nil, timestamp: timestamp)
        do {
            let jsonData = try JSONEncoder().encode(updateData)
            let updatedTodo: Todo = try await networkService.fetchWithAuth("/todos/\(todo.id)", token: token, method: "PATCH", body: jsonData)
            if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                todos[index] = updatedTodo
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTodo(_ todo: Todo) async {
        guard let token = authManager.getAuthToken() else { return }

        do {
            try await networkService.fetchWithAuthNoContent("/todos/\(todo.id)", token: token)
            todos.removeAll { $0.id == todo.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
