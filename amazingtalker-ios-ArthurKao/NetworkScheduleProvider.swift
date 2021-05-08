//
//  NetworkScheduleProvider.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
import amazingtalker_ios_network

extension ScheduleItem: ScheduleItemType {}

class NetworkScheduleProvider: ScheduleProviderType {

    let teacher: String

    init(teacher: String) {
        self.teacher = teacher
    }

    private let manager = NetworkManager()

    func fetch(startAt: Date, completion: @escaping ((Result<[ScheduleItemType], Swift.Error>) -> Void)) {
        manager.retrieveSchedule(teacher: teacher, startAt: startAt) { result in
            completion(result.map { $0 })
        }
    }
}
