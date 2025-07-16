import SwiftUI

struct MoodView: View {
    @ObservedObject private var moodManager: MoodManager
    @State private var selectedMood: MoodEnum? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    init(authManager: AuthManager) {
        self._moodManager = ObservedObject(wrappedValue: MoodManager(authManager: authManager))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How do you feel today?")
                    .font(.title2)
                    .padding(.top, 32)
                if isLoading {
                    ProgressView()
                } else {
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
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Spacer()
            }
            .navigationTitle("Mood")
            .onAppear {
                Task {
                    await loadTodayMood()
                }
            }
        }
    }

    private func icon(for mood: MoodEnum) -> String {
        switch mood {
        case .terrible: return "😡" // very red, mouth very down
        case .bad: return "🙁"      // a little red, mouth a little down
        case .ok: return "😐"       // yellow, neutral mouth
        case .good: return "🙂"     // green, mouth a little up
        case .excellent: return "😄"// very green, mouth very up
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
        isLoading = true
        errorMessage = nil
        do {
            let mood = try await moodManager.fetchTodayMood()
            selectedMood = mood?.mood
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func setMood(_ mood: MoodEnum) async {
        isLoading = true
        errorMessage = nil
        do {
            try await moodManager.setTodayMood(mood)
            selectedMood = mood
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
