//
//  AppModel.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults
import SwiftUI

class AppModel: ObservableObject {
    static let shared = AppModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isInMainView = Defaults[.accessToken] != nil && Defaults[.hollowConfig] != nil
    
    private init() {
        // Chcek for version update
        UpdateAvailabilityRequest.defaultPublisher
            .sinkOnMainThread(receiveValue: VersionUpdateUtilities.handleUpdateAvailabilityResult)
            .store(in: &cancellables)
    }
}
