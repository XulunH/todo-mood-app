//
//  TodoListView.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/16/25.
//

import SwiftUI

struct TodoListView: View {
    @StateObject private var todoManager: TodoManager
    @State private var newTodoTitle = ""
    @State private var showingAddTodo = false
    @State private var editingTodo: Todo? = nil

    init(authManager: AuthManager) {
        self._todoManager = StateObject(wrappedValue: TodoManager(authManager: authManager))
    }

    var body: some View {
        NavigationView {
            VStack {
                if todoManager.isLoading {
                    ProgressView("Loading todos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(todoManager.todos) { todo in
                            TodoRowView(todo: todo, todoManager: todoManager) {
                                editingTodo = todo
                            }
                        }
                        .onDelete(perform: deleteTodos)
                    }
                }
            }
            .navigationTitle("My Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTodo = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(todoManager: todoManager)
            }
            .sheet(item: $editingTodo) { todo in
                EditTodoListView(todo: todo, todoManager: todoManager)
            }
            .refreshable {
                await todoManager.fetchTodos()
            }
        }
        .onAppear {
            Task {
                await todoManager.fetchTodos()
            }
        }
    }

    private func deleteTodos(offsets: IndexSet) {
        Task {
            for index in offsets {
                await todoManager.deleteTodo(todoManager.todos[index])
            }
        }
    }
}

struct TodoRowView: View {
    let todo: Todo
    let todoManager: TodoManager
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack {
            Button(action: {
                Task {
                    await todoManager.updateTodo(todo, completed: !todo.completed)
                }
            }) {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.completed ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())

            Text(todo.title)
                .strikethrough(todo.completed)
                .foregroundColor(todo.completed ? .gray : .primary)
                .onTapGesture {
                    onTap?()
                }

            Spacer()

            Text(formatDate(todo.timestamp))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
}
