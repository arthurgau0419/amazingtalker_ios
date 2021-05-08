//
//  PreviewScheduleProvider.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
import UIKit.NSDataAsset
import amazingtalker_ios_network

struct PreviewScheduleItem: ScheduleItemType {
    let booked: Bool
    let range: ClosedRange<Date>
}

struct PreviewScheduleProvider: ScheduleProviderType {

    let result: Result<[PreviewScheduleItem], Error>

    func fetch(startAt: Date, completion: @escaping ((Result<[ScheduleItemType], Error>) -> Void)) {
        completion(result.map { $0 })
    }

    init(_ result: Result<[PreviewScheduleItem], Error> = .success(PreviewScheduleProvider.defaultItems)) {
        self.result = result
    }

    static var defaultItems: [PreviewScheduleItem] {
        let data = NSDataAsset(name: "CalendarData")!.data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let items = (try? decoder.decode(Schedule.self, from: data))?.items ?? []
        return items.map {
            PreviewScheduleItem(booked: $0.booked, range: $0.range)
        }
    }
}
