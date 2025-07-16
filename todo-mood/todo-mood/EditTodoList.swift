//
//  EditTodoList.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/16/25.
//

import Foundation
import SwiftUI

struct EditTodoListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var date: Date
    let todo: Todo
    let todoManager: TodoManager

    init(todo: Todo, todoManager: TodoManager) {
        self.todo = todo
        self.todoManager = todoManager
        _title = State(initialValue: todo.title)
        if let parsedDate = ISO8601DateFormatter().date(from: todo.timestamp) {
            _date = State(initialValue: parsedDate)
        } else {
            _date = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Todo title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Spacer()
            }
            .navigationTitle("Edit Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await todoManager.updateTodo(todo, title: title, date: date)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
