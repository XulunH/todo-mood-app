//
//  NetworkService.swift
//  todo-mood
//
//  Created by Shuting Fang on 7/16/25.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:8000"

    private init() {}

    // Generic function to make API calls
    func fetch<T: Codable>(_ endpoint: String, method: String = "GET", body: Data? = nil, contentType: String = "application/json") async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NetworkError.apiError(errorResponse.detail)
            } else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    // Add this to NetworkService
    func fetchWithAuthNoContent(_ endpoint: String, token: String, method: String = "DELETE") async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        if httpResponse.statusCode >= 400 {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
    // New method for authenticated requests
    func fetchWithAuth<T: Codable>(_ endpoint: String, token: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NetworkError.apiError(errorResponse.detail)
            } else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .apiError(let message):
            return message
        }
    }
}
