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

    @Published var moodsByDate: [String: MoodEnum] = [:] // "yyyy-MM-dd": MoodEnum

    func fetchMoodsForMonth(year: Int, month: Int) async {
        moodsByDate = [:]
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: calendar.date(from: DateComponents(year: year, month: month, day: 1))!)!
        for day in range {
            let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
            let dateString = DateFormatter.yyyyMMdd.string(from: date)
            do {
                if let mood = try await fetchMood(for: dateString) {
                    moodsByDate[dateString] = mood.mood
                }
            } catch {
                // No mood for this day
            }
        }
    }

    func fetchMood(for date: String) async throws -> MoodOut? {
        guard let token = authManager.getAuthToken() else { return nil }
        let endpoint = "/moods/" + date
        return try await networkService.fetchWithAuth(endpoint, token: token)
    }
}
