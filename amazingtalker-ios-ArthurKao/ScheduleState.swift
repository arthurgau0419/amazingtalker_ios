//
//  ScheduleState.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
import Combine

protocol ScheduleItemType {
    var booked: Bool { get }
    var range: ClosedRange<Date> { get }
}

protocol ScheduleProviderType {
    func fetch(startAt: Date, completion: @escaping ((Result<[ScheduleItemType], Error>) -> Void))
}

class ScheduleState: ObservableObject {

    let provider: ScheduleProviderType
    let hidePassItems: Bool

    let calendar = Calendar(identifier: .gregorian)
    let year: Int
    var weekOfYear: Int {
        didSet {
            updateWeekdayItems()
        }
    }

    private var items: [ScheduleItemType]?

    @Published
    var isLoading: Bool = false

    @Published
    var weekdayItems: [WeekdayItem] = []

    @Published
    var rangeText: String = ""

    @Published
    var timeZoneName: String = ""

    init(referenceDate: Date = Date(), hidePassItems: Bool = true, provider: ScheduleProviderType) {
        self.provider = provider
        self.hidePassItems = hidePassItems
        let dateComponents = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: referenceDate)
        year = dateComponents.yearForWeekOfYear ?? 1970
        weekOfYear = dateComponents.weekOfYear ?? 0
        updateWeekdayItems()
    }

    private func latest8days() -> [Date] {
        var dates = (1...7).map {
            DateComponents(calendar: .current, weekday: $0, weekOfYear: self.weekOfYear, yearForWeekOfYear: self.year).date
        }
        dates.append(DateComponents(calendar: .current, weekday: 1, weekOfYear: self.weekOfYear + 1, yearForWeekOfYear: self.year).date)
        return dates.compactMap { $0 }
    }

    func updateWeekdayItems() {
        let today = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: Date())) ?? Date()
        let weekdaySymbols = DateFormatter().shortWeekdaySymbols
        let dates = latest8days()
        let timeFormatter = DateFormatter()
        timeFormatter.calendar = calendar
        timeFormatter.dateFormat = "HH:mm"

        weekdayItems = dates.prefix(7).enumerated().compactMap {
            guard let weekdaySymbol = weekdaySymbols?[$0.offset],
                  let day = self.calendar.dateComponents([.day], from: $0.element).day
            else { return nil }
            let range = $0.element..<dates[$0.offset+1]
            let now = Date()
            let times = (self.items ?? []).lazy
                .filter { item in
                    (item.range.lowerBound > now) || !self.hidePassItems
                }
                .filter { item in
                    range.overlaps(item.range)
                }
                .map { item in
                    WeekdayItem.Time(text: timeFormatter.string(from: item.range.lowerBound), isBooked: item.booked)
                }

            return WeekdayItem(
                date: $0.element,
                day: String(format: "%02ld", day),
                weekdaySymbol: weekdaySymbol,
                times: Array(times),
                isEnable: $0.element >= today
            )
        }
        if let from = dates.first, let to = dates.last {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let fromDate = formatter.string(from: from)
            formatter.dateFormat = "dd"
            let toDate = formatter.string(from: to)
            rangeText = [fromDate, toDate].joined(separator: " - ")
        }
        if let regionCode = Calendar.current.locale?.regionCode,
           let localizedName = calendar.locale?.localizedString(forRegionCode: regionCode),
           let abbreviation = calendar.timeZone.abbreviation()  {
            timeZoneName = "\(localizedName)(\(abbreviation)"
        }
    }

    func nextWeek() {
        weekOfYear += 1
        loadData()
    }

    func previousWeek() {
        weekOfYear -= 1
        loadData()
    }

    func loadData() {
        guard let queryDate = DateComponents(calendar: calendar, weekOfYear: weekOfYear, yearForWeekOfYear: year).date else {
            return
        }
        isLoading = true
        provider.fetch(startAt: queryDate) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let items):
                self?.items = items
                self?.updateWeekdayItems()
            case .failure(let error):
                print(error)
            }
        }
    }
}


struct WeekdayItem {
    let date: Date
    let day: String
    let weekdaySymbol: String
    let times: [Time]
    let isEnable: Bool

    struct Time {
        let text: String
        let isBooked: Bool
    }
}

extension WeekdayItem: Identifiable {
    var id: Date { date }
}

extension WeekdayItem.Time: Identifiable {
    var id: String { text }
}

