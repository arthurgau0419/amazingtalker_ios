//
//  NetworkManagerTests.swift
//  amazingtalker-ios-networkTests
//
//  Created by Arthur Kao on 2021/5/8.
//

import XCTest
@testable import amazingtalker_ios_network
import Combine

class NetworkManagerTests: XCTestCase {

    let manager = NetworkManager()
    let teacher = "amy-estrada"
    let startAt: Date = {
        DateComponents(calendar: .current, year: 2021, month: 5, day: 8).date!
    }()

    func testCanRequestData() {
        var cancellable: AnyCancellable?
        let expectation = expectation(description: "response")
        cancellable = manager.retrieveSchedule(teacher: teacher, startAt: startAt)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { scheduleItems in
                XCTAssertEqual(scheduleItems.count, 29)
                XCTAssertEqual(scheduleItems.filter(\.booked).count, 13)
                XCTAssertGreaterThan(
                    scheduleItems.last?.range.lowerBound.timeIntervalSince1970 ?? 0,
                    scheduleItems.first?.range.lowerBound.timeIntervalSince1970 ?? 0
                )
            }
        waitForExpectations(timeout: 10) { error in
            _ = cancellable
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }

    }
}
