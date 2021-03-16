//
//  HollowInputStore.swift
//  Hollow
//
//  Created by liang2kls on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Defaults

class HollowInputStore: ObservableObject, AppModelEnvironment, ImageCompressStore {
    var presented: Binding<Bool>
    var refreshHandler: (() -> Void)?
    
    @Published var text: String = ""
    @Published var image: UIImage?
    @Published var compressedImage: UIImage?
    var compressedImageBase64String: String?
    @Published var availableTags: [String] = Defaults[.hollowConfig]?.sendableTags ?? []
    @Published var selectedTag: String?
    @Published var voteInformation: VoteInformation?
    @Published var sending = false
    @Published var errorMessage: (title: String, message: String)?
    @Published var imageSizeInformation: String?
    @Published var appModelState = AppModelState()
    
    var cancellables = Set<AnyCancellable>()
    
    init(presented: Binding<Bool>, refreshHandler: (() -> Void)?) {
        self.presented = presented
        self.refreshHandler = refreshHandler
    }
    
    func newVote() {
        self.voteInformation = .init(options: ["", "", ""])
    }
    
    func sendPost() {
        withAnimation { sending = true }
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }

        let request = SendPostRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token, text: text, tag: selectedTag, imageData: compressedImageBase64String, voteData: voteInformation?.options))
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                self.sending = false
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                self.refreshHandler?()
                self.presented.wrappedValue = false
                // TODO: Show detail or refresh
            })
            .store(in: &cancellables)
    }
}

extension HollowInputStore {
    struct VoteInformation {
        var options: [String]
        var hasDuplicate: Bool {
            var optionsWithoutEmptyString = options
            optionsWithoutEmptyString.removeAll(where: { $0 == "" })
            return Set(optionsWithoutEmptyString).count != optionsWithoutEmptyString.count
        }
        
        static let maxVoteOptionCharacters = 15
        var valid: Bool {
            for option in options {
                if option == "" || option.count > VoteInformation.maxVoteOptionCharacters { return false }
            }
            return !hasDuplicate
        }
        
        func optionHasDuplicate(_ text: String) -> Bool {
            guard text != "" else { return false }
            var count: Int = 0
            for option in options {
                if text == option { count += 1 }
            }
            return count > 1
        }
    }
}
