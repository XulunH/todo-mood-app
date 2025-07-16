import SwiftUI

struct MoodCalendarView: View {
    @Binding var currentMonth: Date
    let moodsByDate: [String: MoodEnum]
    let icon: (MoodEnum) -> String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(currentMonth))
                    .font(.headline)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            let days = generateCalendarDays(for: currentMonth)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)

            // Day headers
            HStack {
                ForEach(["S","M","T","W","T","F","S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(days) { day in
                    Group {
                        if day.isCurrentMonth {
                            let dateString = DateFormatter.yyyyMMdd.string(from: day.date)
                            let isToday = Calendar.current.isDate(day.date, inSameDayAs: Date())
                            VStack(spacing: 4) {
                                if let mood = moodsByDate[dateString] {
                                    Text(icon(mood))
                                        .font(.system(size: 20))
                                } else {
                                    Text("○")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                                Text("\(day.day)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            .padding(4)
                            .background(isToday ? Color.blue.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isToday ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                        } else {
                            Text("")
                        }
                    }
                    .frame(height: 40)
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }

    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    private func generateCalendarDays(for date: Date) -> [CalendarDay] {
        var days: [CalendarDay] = []
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        guard let year = comps.year, let month = comps.month else { return [] }
        let firstOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        // Add leading blanks
        for _ in 1..<weekday { days.append(CalendarDay(date: Date(), day: 0, isCurrentMonth: false)) }
        // Add days of month
        for day in range {
            let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
            days.append(CalendarDay(date: date, day: day, isCurrentMonth: true))
        }
        // Optionally add trailing blanks to fill the grid
        while days.count % 7 != 0 { days.append(CalendarDay(date: Date(), day: 0, isCurrentMonth: false)) }
        return days
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let day: Int
    let isCurrentMonth: Bool
}
