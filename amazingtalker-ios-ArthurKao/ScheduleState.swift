//
//  ScheduleState.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
import Combine

class ScheduleState: ObservableObject {

    let calendar = Calendar(identifier: .gregorian)
    let year: Int
    var weekOfYear: Int {
        didSet {
            updateWeekayItems()
        }
    }

    @Published
    var weekdayItems: [WeekdayItem] = []

    @Published
    var rangeText: String = ""

    @Published
    var timeZoneName: String = ""

    init(referenceDate: Date = Date()) {
        let dateComponents = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: referenceDate)
        year = dateComponents.yearForWeekOfYear ?? 1970
        weekOfYear = dateComponents.weekOfYear ?? 0
        updateWeekayItems()
    }

    func updateWeekayItems() {
        let today = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: Date())) ?? Date()
        let dates = (1...7).compactMap {
            DateComponents(calendar: .current, weekday: $0, weekOfYear: self.weekOfYear, yearForWeekOfYear: self.year).date
        }
        let weekdaySymbols = DateFormatter().shortWeekdaySymbols
        let nextWeekDay1 = DateComponents(calendar: .current, weekday: 1, weekOfYear: self.weekOfYear + 1, yearForWeekOfYear: self.year).date
        weekdayItems = dates.enumerated().compactMap {
            guard let weekdaySymbol = weekdaySymbols?[$0.offset],
                  let day = self.calendar.dateComponents([.day], from: $0.element).day
            else { return nil }
            return WeekdayItem(
                date: $0.element,
                day: String(format: "%02ld", day),
                weekdaySymbol: weekdaySymbol,
                times: [],
                isEnable: $0.element >= today
            )
        }
        if let from = dates.first, let to = dates.last {
            let formatter = DateIntervalFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            rangeText = formatter.string(from: from, to: to)
        }
        if let localizedName = calendar.timeZone.localizedName(for: .standard, locale: .current),
           let abbreviation = calendar.timeZone.abbreviation()  {
            timeZoneName = "\(localizedName)(\(abbreviation)"
        }
    }

    func nextWeek() { weekOfYear += 1 }

    func previousWeek() { weekOfYear -= 1 }
}


struct WeekdayItem {
    let date: Date
    let day: String
    let weekdaySymbol: String
    let times: [Date]
    let isEnable: Bool
}

extension WeekdayItem: Identifiable {
    var id: Date { date }
}
