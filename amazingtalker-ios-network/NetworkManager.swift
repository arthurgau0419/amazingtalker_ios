//
//  NetworkManager.swift.swift
//  amazingtalker-ios-network
//
//  Created by Arthur Kao on 2021/5/8.
//

import Foundation
import class UIKit.NSDataAsset

public class NetworkManager {

    enum Error: Swift.Error {
        case formURLFailed
        case noResponseData
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

    public func retrieveSchedule(teacher: String, startAt: Date, completion: @escaping ((_ items: Result<[ScheduleItem], Swift.Error>) -> Void)) {

        guard let path = "v1/guest/teachers/\(teacher)/schedule".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(.failure(Error.formURLFailed))
            return
        }
        let url = host.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(Error.formURLFailed))
            return
        }
        components.queryItems = [URLQueryItem(name: "started_at", value: dateFormatter.string(from: startAt))]
        guard let url = components.url else {
            completion(.failure(Error.formURLFailed))
            return
        }

        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [queue = self.queue] data, response, error in
            queue.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(Error.noResponseData))
                    return
                }
                let result = Result { [decoder = self.decoder] in
                    try decoder.decode(Schedule.self, from: data).items
                }
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
        task.resume()
    }
}
