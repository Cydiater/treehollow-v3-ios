//
//  IntegrationUtilities.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct IntegrationUtilities {
    static func topViewController() -> UIViewController? {
        let keyWindow = IntegrationUtilities.keyWindow()

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    static func keyWindow() -> UIWindow? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
    
    static func presentView<Content: View>(presentationStyle: UIModalPresentationStyle = .popover, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder content: () -> Content) {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = nil
        vc.modalPresentationStyle = presentationStyle
        vc.modalTransitionStyle = transitionStyle
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        topVC.present(vc, animated: true)
    }
    
    static func setCustomColorScheme(_ colorScheme: CustomColorScheme = Defaults[.colorScheme]) {
        keyWindow()?.overrideUserInterfaceStyle =
            colorScheme == .system ? .unspecified :
            colorScheme == .light ? .light : .dark
    }
}
