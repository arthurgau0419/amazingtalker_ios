//
//  DecodableTests.swift
//  amazingtalker-ios-ArthurKaoTests
//
//  Created by Arthur Kao on 2021/5/8.
//

import XCTest
@testable import amazingtalker_ios_network

class DecodableTests: XCTestCase {

    lazy var data: Data = {
        NSDataAsset(name: "CalendarData")?.data ?? Data()
    }()

    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func testCanReadJsonData() {
        XCTAssertGreaterThan(data.count, 0)
    }

    func testDecode() {
        do {
            let schedule = try decoder.decode(Schedule.self, from: data)
            XCTAssertGreaterThan(schedule.items.count, 0)
            XCTAssertLessThan(
                schedule.items.first?.range.lowerBound.timeIntervalSince1970 ?? 0,
                schedule.items.last?.range.lowerBound.timeIntervalSince1970 ?? 0
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}


