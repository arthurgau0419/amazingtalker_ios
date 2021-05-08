//
//  DataModel.swift
//  amazingtalker-ios-network
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation

public struct Schedule: Decodable {
    typealias Item = ScheduleItem

    public let items: [ScheduleItem]

    enum CodingKeys: String, CodingKey {
        case available
        case booked
    }

    enum ItemKeys: String, CodingKey {
        case start, end
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var availableContainer = try container.nestedUnkeyedContainer(forKey: .available)
        var bookedContainer = try container.nestedUnkeyedContainer(forKey: .booked)
        var availableDates = Set<ClosedRange<Date>>()
        var bookedDates = Set<ClosedRange<Date>>()

        let decodeDates: ((inout UnkeyedDecodingContainer, inout Set<ClosedRange<Date>>) throws -> Void) = { rangesContainer, set in
            while !rangesContainer.isAtEnd {
                let itemContainer = try rangesContainer.nestedContainer(keyedBy: ItemKeys.self)
                let start = try itemContainer.decode(Date.self, forKey: .start)
                let end = try itemContainer.decode(Date.self, forKey: .end)
                set.insert(start...end)
            }
        }

        try decodeDates(&availableContainer, &availableDates)
        try decodeDates(&bookedContainer, &bookedDates)

        items = (availableDates.map { Item(booked: false, range: $0) } + bookedDates.map { Item(booked: true, range: $0) })
            .sorted { lhs, rhs in
                lhs.range.lowerBound < rhs.range.lowerBound
            }
    }
}

public struct ScheduleItem {
    public let booked: Bool
    public let range: ClosedRange<Date>

    public init(booked: Bool, start: Date, end: Date) {
        self.booked = booked
        self.range = start...end
    }

    public init(booked: Bool, range: ClosedRange<Date>) {
        self.booked = booked
        self.range = range
    }
}

