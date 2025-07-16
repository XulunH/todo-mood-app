import SwiftUI

struct MoodView: View {
    @ObservedObject private var moodManager: MoodManager
    @State private var selectedMood: MoodEnum? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var currentMonth: Date = Date()

    init(authManager: AuthManager) {
        self._moodManager = ObservedObject(wrappedValue: MoodManager(authManager: authManager))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How do you feel today?")
                    .font(.title2)
                    .padding(.top, 32)

                // Always show the emoji buttons to prevent layout shifts
                HStack(spacing: 16) {
                    ForEach(MoodEnum.allCases) { mood in
                        Button(action: {
                            Task {
                                await setMood(mood)
                            }
                        }) {
                            VStack {
                                Text(icon(for: mood))
                                    .font(.system(size: 40))
                                    .padding(8)
                                    .background(selectedMood == mood ? color(for: mood).opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(color(for: mood), lineWidth: selectedMood == mood ? 3 : 1)
                                    )
                                Text(mood.rawValue.capitalized)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                MoodCalendarView(currentMonth: $currentMonth, moodsByDate: moodManager.moodsByDate, icon: icon)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer()
            }
            .navigationTitle("Mood")
            .background(Color.orange.opacity(0.1))
            .onAppear {
                Task {
                    await loadTodayMood()
                    await fetchMonthMoods()
                }
            }
        }
    }

    private func icon(for mood: MoodEnum) -> String {
        switch mood {
        case .terrible: return "😡"
        case .bad: return "🙁"
        case .ok: return "😐"
        case .good: return "🙂"
        case .excellent: return "😄"
        }
    }

    private func color(for mood: MoodEnum) -> Color {
        switch mood {
        case .terrible: return .red
        case .bad: return .orange
        case .ok: return .yellow
        case .good: return .green
        case .excellent: return .mint
        }
    }

    private func loadTodayMood() async {
        errorMessage = nil
        do {
            let mood = try await moodManager.fetchTodayMood()
            selectedMood = mood?.mood
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func setMood(_ mood: MoodEnum) async {
        // Don't show loading state for mood selection to avoid screen refresh
        errorMessage = nil

        // Immediately update the local state to prevent visual gaps
        selectedMood = mood
        moodManager.updateTodayMoodLocally(mood)

        do {
            try await moodManager.setTodayMood(mood)
            // Refresh the calendar in the background to ensure consistency
            await fetchMonthMoods()
        } catch {
            errorMessage = error.localizedDescription
            // Revert the local state if the API call failed
            selectedMood = nil
            moodManager.updateTodayMoodLocally(.ok) // Reset to default or remove
        }
    }
    private func fetchMonthMoods() async {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let year = comps.year, let month = comps.month else { return }
        await moodManager.fetchMoodsForMonth(year: year, month: month)
    }
}
