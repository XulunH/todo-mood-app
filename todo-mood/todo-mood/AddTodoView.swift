//
//  AddTodoView.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/16/25.
//

import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedDate = Date()
    let todoManager: TodoManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Todo title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Spacer()
            }
            .navigationTitle("Add Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            await todoManager.addTodo(title: title, date: selectedDate)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
