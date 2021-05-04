//
//  UpdateAvailabilityRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults
import Alamofire
import Combine
import UIKit

struct UpdateAvailabilityRequestResult: Codable {
    struct Result: Codable {
        var minimumOsVersion: String
        var trackViewUrl: String
        var currentVersionReleaseDate: String
        var releaseNotes: String
        var version: String
    }
    var results: [Result]
}

struct UpdateAvailabilityRequest: Request {
    typealias Configuration = Void
    typealias Result = UpdateAvailabilityRequestResult
    typealias ResultData = (Bool, UpdateAvailabilityRequestResult.Result)
    typealias Error = DefaultRequestError
    
    static var defaultPublisher: AnyPublisher<ResultData?, Never> {
        return UpdateAvailabilityRequest(configuration: ()).publisher
            .map({ Optional($0) })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var configuration: Void
    
    init(configuration: Void) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, DefaultRequestError?) -> Void) {
        if UIDevice.isMac {
            // FIXME: Seems that we cannot get macOS version info with the same bundle id.
            completion(nil, nil)
            return
        }
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String,
              let identifier = info["CFBundleIdentifier"] as? String,
              let url = URL(string: "http://itunes.apple.com/cn/lookup?bundleId=\(identifier)") else {
            completion(nil, .unknown)
            return
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, .unknown)
                return
            }
            
            guard let result = try? JSONDecoder().decode(Result.self, from: data),
                  !result.results.isEmpty else {
                completion(nil, .decodeFailed)
                return
            }
            
            let updateAvailable = isUpdateAvailable(currentVersion: currentVersion, fetchedVersion: result.results.first!.version)
            completion((updateAvailable, result.results.first!), nil)
            completion(nil, .loadingCompleted)
        }
        task.resume()
    }
    
    private func isUpdateAvailable(currentVersion: String, fetchedVersion: String) -> Bool {
        let currentNumbers = currentVersion.split(separator: ".").compactMap({ Int($0) })
        let fetchedNumbers = fetchedVersion.split(separator: ".").compactMap({ Int($0) })
        let minDigits = min(currentNumbers.count, fetchedNumbers.count)
        
        // e.g. 3.0.1 > 3.0.0; 3.1.0 > 3.0
        for index in 0..<minDigits {
            if currentNumbers[index] < fetchedNumbers[index] { return true }
            if currentNumbers[index] > fetchedNumbers[index] { return false }
        }
        
        // e.g. 3.0.1 > 3.0
        return fetchedNumbers.count > currentNumbers.count
    }

}
