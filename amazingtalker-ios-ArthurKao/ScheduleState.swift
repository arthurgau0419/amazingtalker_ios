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
    var range: Range<Date> { get }
}

protocol ScheduleProviderType {
    func fetch(startAt: Date) -> AnyPublisher<[ScheduleItemType], Error>
}

class ScheduleState: ObservableObject {

    let provider: ScheduleProviderType
    let hidePassItems: Bool

    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        return calendar
    }()
    let year: Int

    @Published
    var weekOfYear: Int

    @Published
    var pageVector: Int = 0

    @Published
    var canGoBack: Bool = true

    private var items = CurrentValueSubject<[ScheduleItemType], Never>([])

    private var fetchScheduleCancellable: AnyCancellable?
    private var bag = Set<AnyCancellable>()

    private let queue = DispatchQueue(label: "state.serial.queue")

    @Published
    var isLoading: Bool = false

    @Published
    var weekdayItems: [WeekdayItem] = []

    @Published
    var weekdayItemsAnimationFlag = false

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
        observeWeekOfYear()
        observeItems()
    }

    private func latest8days(year: Int, weekOfYear: Int) -> [Date] {
        var dates = (1...7).map {
            DateComponents(calendar: .current, weekday: $0, weekOfYear: weekOfYear, yearForWeekOfYear: year).date
        }
        dates.append(DateComponents(calendar: .current, weekday: 1, weekOfYear: weekOfYear + 1, yearForWeekOfYear: year).date)
        return dates.compactMap { $0 }
    }

    func observeWeekOfYear() {
        $weekOfYear
            .compactMap { [calendar = self.calendar, year = self.year] weekOfYear in
                DateComponents(calendar: calendar, weekOfYear: weekOfYear, yearForWeekOfYear: year).date
            }
            .flatMap { [provider = self.provider, self] date in
                provider.fetch(startAt: date)
                    .handleEvents(receiveSubscription: { [weak self] _ in
                        self?.isLoading = true
                    }, receiveCompletion: { [weak self] _ in
                        self?.isLoading = false
                    })
            }
            .replaceError(with: [])
            .multicast(subject: items)
            .connect()
            .store(in: &bag)

        Publishers.CombineLatest(
            $weekOfYear
                .compactMap { [calendar = self.calendar, year = self.year] weekOfYear in
                    DateComponents(calendar: calendar, weekOfYear: weekOfYear - 1, yearForWeekOfYear: year).date
                },
            $weekOfYear
                .compactMap { [calendar = self.calendar, year = self.year] weekOfYear in
                    DateComponents(calendar: calendar, weekOfYear: weekOfYear, yearForWeekOfYear: year).date
                }
        )
        .map { ($0.0 ..< $0.1) as Range<Date> }
        .map { range -> Bool in
            let future = Date()...
            return future.contains(range.lowerBound) || future.contains(range.upperBound)
        }
        .map { $0 || !self.hidePassItems }
        .assign(to: \.canGoBack, on: self)
        .store(in: &bag)
    }

    func observeItems() {

        let datesConnectable = Publishers.CombineLatest(Just(year), $weekOfYear.eraseToAnyPublisher())
            .map { year, weekOfYear in
                self.latest8days(year: year, weekOfYear: weekOfYear)
            }
            .makeConnectable()
        let dates = datesConnectable.share()

        dates.combineLatest(items)
            .receive(on: queue)
            .map { [calendar = self.calendar] dates, items in
                let today = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: Date())) ?? Date()
                let weekdaySymbols = DateFormatter().shortWeekdaySymbols

                let timeFormatter = DateFormatter()
                timeFormatter.calendar = calendar
                timeFormatter.dateFormat = "HH:mm"

                return dates.prefix(7).enumerated()
                    .compactMap {
                        guard let weekdaySymbol = weekdaySymbols?[$0.offset],
                              let day = self.calendar.dateComponents([.day], from: $0.element).day
                        else { return nil }
                        let range = $0.element..<dates[$0.offset+1]
                        let now = Date()

                        let validTimes = items.lazy
                            .filter { item in
                                (item.range.lowerBound > now) || !self.hidePassItems
                            }
                            .filter { item in
                                range.overlaps(item.range)
                            }

                        let emptyTimes = validTimes.filter { !$0.booked }
                        let bookedTimes = validTimes.filter(\.booked)

                        let bookedSet = bookedTimes.reduce(into: Set<Date>()) { set, time in
                            var start = time.range.lowerBound
                            if start < range.lowerBound {
                                start = range.lowerBound
                            }
                            repeat {
                                set.insert(start)
                                start = start.advanced(by: 30 * 60)
                            } while (start < time.range.upperBound) && (range.upperBound > start)
                        }
                        let emptySet = emptyTimes.reduce(into: Set<Date>()) { set, time in
                            var start = time.range.lowerBound
                            if start < range.lowerBound {
                                start = range.lowerBound
                            }
                            repeat {
                                set.insert(start)
                                start = start.advanced(by: 30 * 60)
                            } while (start < time.range.upperBound) && (range.upperBound > start)
                        }
                        // ????????????
                        .subtracting(bookedSet)

                        let times = (
                            emptySet.map {
                                WeekdayItem.Time(text: timeFormatter.string(from: $0), isBooked: false)
                            } +
                            bookedSet.map {
                                WeekdayItem.Time(text: timeFormatter.string(from: $0), isBooked: true)
                            }
                        ).sorted { lhs, rhs in
                            lhs.text < rhs.text
                        }

                        return WeekdayItem(
                            date: $0.element,
                            day: String(format: "%02ld", day),
                            weekdaySymbol: weekdaySymbol,
                            times: Array(times),
                            isEnable: $0.element >= today
                        )
                    }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.weekdayItems, on: self)
            .store(in: &bag)

        dates.map { $0.prefix(7) }
            .receive(on: queue)
            .compactMap { dates in
                guard let from = dates.first, let to = dates.last else { return nil }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                let fromDate = formatter.string(from: from)
                formatter.dateFormat = "dd"
                let toDate = formatter.string(from: to)
                return [fromDate, toDate].joined(separator: " - ")
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.rangeText, on: self)
            .store(in: &bag)

        Just(calendar.locale).compactMap { $0 }
            .zip(Just(calendar.locale?.regionCode).compactMap { $0 })
            .compactMap { locale, regionCode in locale.localizedString(forRegionCode: regionCode) }
            .zip(Just(calendar.timeZone.abbreviation()).compactMap { $0 })
            .map { locale, abbreviation -> String in
                "\(locale)(\(abbreviation))"
            }
            .assign(to: \.timeZoneName, on: self)
            .store(in: &bag)

        $weekdayItems
            .filter { !$0.isEmpty }
            .throttle(for: .milliseconds(150), scheduler: DispatchQueue.main, latest: false)
            .flatMap { _ in
                Just(false).merge(with: Just(true).delay(for: .milliseconds(150), scheduler: DispatchQueue.main))
            }
            .assign(to: \.weekdayItemsAnimationFlag, on: self)
            .store(in: &bag)

        datesConnectable.connect().store(in: &bag)
    }

    func nextWeek() {
        pageVector = 1
        weekOfYear += 1
    }

    func previousWeek() {
        pageVector = -1
        weekOfYear -= 1
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

