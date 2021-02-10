//
//  AccountCreation.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Alamofire
import UIKit
import Foundation

/// Configuraions for creating an account.
struct AccountCreationRequestConfiguration {
    /// User's email.
    var email: String
    /// store passwd
    var password: String
    /// Device type, 2 for iOS.
    let deviceType = 2
    /// Device information.
    let deviceInfo: String = Constants.Application.deviceInfo
    /// Old thuhole token (only needed for old users signing up using web frontend),
    /// optional, but one of `validCode` and `oldToken` must be present.
    // var oldToken: String?
    /// Email valid code, optional, but one of `oldToken` and `validCode` must be present.
    var validCode: String?
    // TODO: Device token for APNs
    var deviceToken: String
    /// See `AccountCreationConfiguration`
    ///
    var apiRoot: String
}

/// Result of account creation attempt.
struct AccountCreationRequestResultData {
    /// Result type of account creation.
    ///
    /// Please init with `AccountCreationRequestResult.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
//        enum ResultType: Int {
//            case success = 0
//        }
//        /// The type of result received.
//    var code: ResultType
    /// Access token.
    var token: String
    /// Device UUID
    var uuid: UUID
    /// Error mssage.
    //var message: String?
}

struct AccountCreationRequestResult: DefaultRequestResult {
    /// The type of result received.
    var code: Int
    /// Access token.
    var token: String?
    /// Device UUID
    var uuid: UUID?
    /// Error mssage.
    var msg: String?
}

struct AccountCreationRequest: DefaultRequest {
    typealias Configuration = AccountCreationRequestConfiguration
    typealias Result = AccountCreationRequestResult
    typealias ResultData = AccountCreationRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: AccountCreationRequestConfiguration
    
    init(configuration: AccountCreationRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(
        completion: @escaping (ResultData?, Error?) -> Void
    ) {
        var parameters = [
            "email": self.configuration.email,
            "password_hashed": self.configuration.password.sha256().sha256(),
            "device_type": self.configuration.deviceType.string,
            "device_info": self.configuration.deviceInfo,
            "ios_device_token": self.configuration.deviceToken,
        ]
        
        if let validCode = self.configuration.validCode {
            parameters["valid_code"] = validCode
        }
        
        let urlPath =
            self.configuration.apiRoot + "v3/security/login/create_account" + Constants.URLConstant.urlSuffix
        performRequest(
            urlPath: urlPath,
            parameters: parameters,
            method: .post,
            resultToResultData: { result in
                guard let token = result.token, let uuid = result.uuid else { return nil }
                return ResultData(token: token, uuid: uuid)
            },
            completion: completion
        )
    }
}
