import Foundation

@MainActor
class MoodManager: ObservableObject {
    private let networkService = NetworkService.shared
    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func fetchTodayMood() async throws -> MoodOut? {
        guard let token = authManager.getAuthToken() else { return nil }
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10) // yyyy-MM-dd
        let endpoint = "/moods/today"
        return try await networkService.fetchWithAuth(endpoint, token: token)
    }

    func setTodayMood(_ mood: MoodEnum) async throws {
        guard let token = authManager.getAuthToken() else { return }
        let moodCreate = MoodCreate(mood: mood)
        let jsonData = try JSONEncoder().encode(moodCreate)
        _ = try await networkService.fetchWithAuth("/moods/today", token: token, method: "POST", body: jsonData) as MoodOut
    }
}
