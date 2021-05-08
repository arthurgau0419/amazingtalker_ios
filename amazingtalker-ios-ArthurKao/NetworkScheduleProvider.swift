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

    private let manager = NetworkManager()

    func fetch(completion: @escaping ((Result<[ScheduleItemType], Error>) -> Void)) {
        manager.retrieveSchedule { result in
            completion(result.map { $0 })
        }
    }
}
