//
//  NetworkManager.swift.swift
//  amazingtalker-ios-network
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
import class UIKit.NSDataAsset
import Combine

public class NetworkManager {

    enum Error: Swift.Error {
        case formURLFailed
    }

    public init() {}

    let host = URL(string: "https://api.amazingtalker.com")!


    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()

    private let queue = DispatchQueue.global()
    private let requestTimeInterval: TimeInterval = 0.6
    private let data = NSDataAsset(name: "CalendarData")?.data ?? Data()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public func retrieveSchedule(teacher: String, startAt: Date) -> AnyPublisher<[ScheduleItem], Swift.Error> {

        guard let path = "v1/guest/teachers/\(teacher)/schedule".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return Fail(error: Error.formURLFailed).eraseToAnyPublisher()
        }
        let url = host.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return Fail(error: Error.formURLFailed).eraseToAnyPublisher()
        }
        components.queryItems = [URLQueryItem(name: "started_at", value: dateFormatter.string(from: startAt))]
        guard let url = components.url else {
            return Fail(error: Error.formURLFailed).eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)
        return URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: queue)
            .map(\.data)
            .decode(type: Schedule.self, decoder: decoder)
            .map(\.items)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
