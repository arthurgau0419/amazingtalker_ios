//
//  NetworkManager.swift.swift
//  amazingtalker-ios-network
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
import class UIKit.NSDataAsset

public class NetworkManager {

    public init() {}

    private let queue = DispatchQueue.global()
    private let requestTimeInterval: TimeInterval = 0.6
    private let data = NSDataAsset(name: "CalendarData")?.data ?? Data()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public func retrieveSchedule(completion: @escaping ((_ items: Result<[ScheduleItem], Error>) -> Void)) {
        queue.asyncAfter(deadline: .now() + requestTimeInterval) {
            let result = Result { [decoder = self.decoder, data = self.data] in
                try decoder.decode(Schedule.self, from: data).items
            }
            completion(result)
        }
    }
}
