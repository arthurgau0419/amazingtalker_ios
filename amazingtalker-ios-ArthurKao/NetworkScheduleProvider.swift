//
//  NetworkScheduleProvider.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
#if os(watchOS)
import amazingtalker_ios_network_watch
#else
import amazingtalker_ios_network
#endif
import Combine

extension ScheduleItem: ScheduleItemType {}

class NetworkScheduleProvider: ScheduleProviderType {

    let teacher: String

    init(teacher: String) {
        self.teacher = teacher
    }

    private let manager = NetworkManager()

    func fetch(startAt: Date) -> AnyPublisher<[ScheduleItemType], Error> {
        manager.retrieveSchedule(teacher: teacher, startAt: startAt)
            .map { items in items.map { item in item as ScheduleItemType } }
            .eraseToAnyPublisher()
    }
}
