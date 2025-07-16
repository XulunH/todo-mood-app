//
//  Models.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/16/25.
//

import Foundation

// MARK: - User Models
struct User: Codable {
    let id: Int
    let email: String
}

struct UserCreate: Codable {
    let email: String
    let password: String
}

// MARK: - Authentication Models
struct Token: Codable {
    let access_token: String
    let token_type: String
}

// MARK: - Todo Models
struct Todo: Codable, Identifiable {
    let id: Int
    let title: String
    let completed: Bool
    let timestamp: String
}

struct TodoCreate: Codable {
    let title: String
    let completed: Bool
    let timestamp: String
}

struct TodoUpdate: Codable {
    let title: String?
    let completed: Bool?
    let timestamp: String?
}

// MARK: - Mood Models

enum MoodEnum: String, CaseIterable, Codable, Identifiable {
    case terrible, bad, ok, good, excellent
    var id: String { self.rawValue }
}

struct MoodCreate: Codable {
    let mood: MoodEnum
}

struct MoodOut: Codable, Identifiable {
    let id: Int
    let mood: MoodEnum
    let date: String // Use String for ISO date
}

// MARK: - API Response Models
struct APIError: Codable {
    let detail: String
}
