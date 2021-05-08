//
//  ScheduleStateTests.swift
//  amazingtalker-ios-ArthurKaoTests
//
//  Created by Arthur Kao on 2021/5/8.
//

import XCTest
@testable import amazingtalker_ios_ArthurKao

class ScheduleStateTests: XCTestCase {

    lazy var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .current
        return calendar
    }()
    lazy var referenceDate: Date = {
        DateComponents(calendar: calendar, year: 2020, month: 11, day: 23).date!
    }()
    var state: ScheduleState!

    override func setUp() {
        state = ScheduleState(referenceDate: referenceDate, hidePassItems: false, provider: PreviewScheduleProvider())
    }

    func testStateWeekdayItemsAndTimes() {
        XCTAssertEqual(state.weekdayItems.count, 7, "一週應該有七天")       
        XCTAssertEqual(state.rangeText, "2020/11/22 - 28")
        XCTAssertFalse(state.timeZoneName.isEmpty)

        XCTAssertEqual(state.weekdayItems[0].day, "22")
        XCTAssertEqual(state.weekdayItems[1].day, "23")
        XCTAssertEqual(state.weekdayItems[2].day, "24")
        XCTAssertEqual(state.weekdayItems[3].day, "25")
        XCTAssertEqual(state.weekdayItems[4].day, "26")
        XCTAssertEqual(state.weekdayItems[5].day, "27")
        XCTAssertEqual(state.weekdayItems[6].day, "28")

        XCTAssertEqual(state.weekdayItems[0].times.count, 0)
        XCTAssertEqual(state.weekdayItems[1].times.count, 1)
        XCTAssertEqual(state.weekdayItems[2].times.count, 0)
        XCTAssertEqual(state.weekdayItems[3].times.count, 2)
        XCTAssertEqual(state.weekdayItems[4].times.count, 0)
        XCTAssertEqual(state.weekdayItems[5].times.count, 0)
        XCTAssertEqual(state.weekdayItems[6].times.count, 3)
    }

    func testPreviousPage() {
        state.previousWeek()
        XCTAssertEqual(state.weekdayItems.count, 7, "一週應該有七天")
        XCTAssertEqual(state.rangeText, "2020/11/15 - 21")
        XCTAssertFalse(state.timeZoneName.isEmpty)

        XCTAssertEqual(state.weekdayItems[0].day, "15")
        XCTAssertEqual(state.weekdayItems[1].day, "16")
        XCTAssertEqual(state.weekdayItems[2].day, "17")
        XCTAssertEqual(state.weekdayItems[3].day, "18")
        XCTAssertEqual(state.weekdayItems[4].day, "19")
        XCTAssertEqual(state.weekdayItems[5].day, "20")
        XCTAssertEqual(state.weekdayItems[6].day, "21")

        XCTAssertEqual(state.weekdayItems[0].times.count, 0)
        XCTAssertEqual(state.weekdayItems[1].times.count, 0)
        XCTAssertEqual(state.weekdayItems[2].times.count, 0)
        XCTAssertEqual(state.weekdayItems[3].times.count, 0)
        XCTAssertEqual(state.weekdayItems[4].times.count, 0)
        XCTAssertEqual(state.weekdayItems[5].times.count, 0)
        XCTAssertEqual(state.weekdayItems[6].times.count, 0)
    }

    func testNextPage() {
        state.nextWeek()
        XCTAssertEqual(state.weekdayItems.count, 7, "一週應該有七天")
        XCTAssertEqual(state.rangeText, "2020/11/29 - 05")
        XCTAssertFalse(state.timeZoneName.isEmpty)

        XCTAssertEqual(state.weekdayItems[0].day, "29")
        XCTAssertEqual(state.weekdayItems[1].day, "30")
        XCTAssertEqual(state.weekdayItems[2].day, "01")
        XCTAssertEqual(state.weekdayItems[3].day, "02")
        XCTAssertEqual(state.weekdayItems[4].day, "03")
        XCTAssertEqual(state.weekdayItems[5].day, "04")
        XCTAssertEqual(state.weekdayItems[6].day, "05")

        XCTAssertEqual(state.weekdayItems[0].times.count, 0)
        XCTAssertEqual(state.weekdayItems[1].times.count, 0)
        XCTAssertEqual(state.weekdayItems[2].times.count, 0)
        XCTAssertEqual(state.weekdayItems[3].times.count, 0)
        XCTAssertEqual(state.weekdayItems[4].times.count, 0)
        XCTAssertEqual(state.weekdayItems[5].times.count, 0)
        XCTAssertEqual(state.weekdayItems[6].times.count, 0)
    }
}
