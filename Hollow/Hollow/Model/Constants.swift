//
//  Constants.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import UIKit

/// Shared constants.
///
/// The purpose of the nested structs is to provide namespaces.
struct Constants {
    struct Application {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        static let deviceInfo = UIDevice.current.name + ", iOS " + UIDevice.current.systemVersion
    }
    
    struct HollowConfig {
        static let thuConfigURL = "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/config.txt"
        static let pkuConfigURL = ""
    }

    struct URLConstant {
        static let urlSuffix = "?v=v\(Constants.Application.appVersion)&device=2"
    }
}
