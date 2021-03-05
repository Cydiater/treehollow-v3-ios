//
//  LoginSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

// Sub views of `LoginView`, we put them here to
// improve code hightlight and completion performance.
extension LoginView {
    struct ReCAPTCHAPageView: View {
        @Binding var presented: Bool
        let successHandler: (String) -> Void
        @State private var pageLoadingFinish = false
        
        @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat

        var body: some View {
            VStack {
                Button(action: {
                    withAnimation {
                        presented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .modifier(ImageButtonModifier())
                        .padding(.bottom)
                }
                .leading()
                ReCAPTCHAWebView(onFinishLoading: {
                    withAnimation {
                        pageLoadingFinish = true
                    }
                }, successHandler: successHandler)
                .onAppear {
                    pageLoadingFinish = false
                }
            }
            .padding()
            .overlay(Group {
                if !pageLoadingFinish {
                    Spinner(color: .buttonGradient1, desiredWidth: 30)
                }
            })
            
        }
    }
    
    struct RegisterTextFields: View {
        @EnvironmentObject var viewModel: Login

        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
        
        // The password is valid only if its length is no less than 8 and it contains no blank spaces.
        private var passwordValid: Bool {
            viewModel.originalPassword.count >= 8 &&
                !viewModel.originalPassword.contains(" ")
        }
        
        private var confirmedPasswordValid: Bool {
            viewModel.confirmedPassword == viewModel.originalPassword
        }
        
        private let passwordRequirements: String =
            NSLocalizedString("LOGINVIEW_PASSWORD_TEXTFIELD_REQUIREMENT_FOOTER", comment: "")
        
        var body: some View {
            // Verification code text field
            MyTextField<EmptyView>(text: $viewModel.emailVerificationCode, title: NSLocalizedString("LOGINVIEW_EMAIL_VERIF_TEXTFIELD_TITLE", comment: ""), footer: NSLocalizedString("LOGINVIEW_EMAIL_VERIF_TEXTFIELD_FOOTER", comment: ""))
                .keyboardType(.numberPad)
            
            // Password text field
            MyTextField(
                text: $viewModel.originalPassword,
                title: NSLocalizedString("LOGINVIEW_PASSWORD_TEXTFIELD_TITLE", comment: ""),
                footer: passwordRequirements,
                isSecureContent: true) {
                Group {
                    if viewModel.originalPassword != "" && !passwordValid {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    } else if viewModel.originalPassword != "" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .font(.system(size: body14))
            }
            
            // Confirmed password text field
            MyTextField(text: $viewModel.confirmedPassword,
                        title: NSLocalizedString("LOGINVIEW_CONFIRMED_PASSWORD_TEXTFIELD_TITLE", comment: ""),
                        isSecureContent: true) {
                Group {
                    // Original password should be valid first.
                    if passwordValid {
                        if viewModel.confirmedPassword != "" && !confirmedPasswordValid {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        } else if viewModel.confirmedPassword != "" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
                .font(.system(size: body14))
            }
        }
    }
    
    struct EmailTextField: View {
        @EnvironmentObject var viewModel: Login
        private let configuration = Defaults[.hollowConfig]!
        
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat

        var body: some View {
            MyTextField(text: $viewModel.email,
                        placeHolder: NSLocalizedString("LOGINVIEW_EMAIL_TEXTFIELD_PLACEHOLDER", comment: ""),
                        title: NSLocalizedString("LOGINVIEW_EMAIL_TEXTFIELD_TITLE", comment: "")) {
                // Accessory view for selecting email suffix
                Menu(content: {
                    ForEach(configuration.emailSuffixes.indices, id: \.self) { index in
                        Button(configuration.emailSuffixes[index], action: {
                            viewModel.emailSuffix = configuration.emailSuffixes[index]
                        })
                    }
                }, label: {
                    HStack {
                        Text("@" + viewModel.emailSuffix)
                        Image(systemName: "chevron.down")
                            .layoutPriority(1)
                    }
                    .lineLimit(1)
                    .font(.system(size: body14))
                    .foregroundColor(.hollowContentText)
                })
            }
            .keyboardType(.emailAddress)
        }
    }
    
    struct LoginTextField: View {
        @EnvironmentObject var viewModel: Login
        @State private var alertPresented = false
        @State private var contactEmailURL: URL!
        @Environment(\.openURL) var openURL
        
        @ScaledMetric(wrappedValue: 12, relativeTo: .footnote) var footnote12: CGFloat

        var body: some View {
            VStack(alignment: .leading) {
                MyTextField<EmptyView>(text: $viewModel.loginPassword,
                                       placeHolder: NSLocalizedString("LOGINVIEW_PASSWORD_TEXTFIELD_PLACEHOLDER", comment: ""),
                                       title: NSLocalizedString("LOGINVIEW_PASSWORD_TEXTFIELD_TITLE", comment: ""),
                                       isSecureContent: true)
                Button(action: {
                    if let mailString = Defaults[.hollowConfig]?.contactEmail,
                       let url = URL(string: "mailto:\(mailString)") {
                        contactEmailURL = url
                        alertPresented = true
                    } else {
                        viewModel.errorMessage = (
                            title: NSLocalizedString("GLOBAL_ERROR_MSG_TITLE", comment: ""),
                            message: NSLocalizedString("LOGINVIEW_NO_CONTACT_EMAIL_ERROR", comment: "")
                        )
                    }
                }) {
                    Text("LOGINVIEW_FORGET_PASSWORD_BUTTON")
                        .underline()
                        .font(.system(size: footnote12))
                        .foregroundColor(.secondary)
                }
            }
            
            .styledAlert(
                presented: $alertPresented,
                title: NSLocalizedString("LOGINVIEW_RESTORE_PASSWORD_ALERT_TITLE", comment: ""),
                message: NSLocalizedString("LOGINVIEW_RESTORE_PASSWORD_ALERT_MESSAGE", comment: ""),
                buttons: [
                    .init(text: NSLocalizedString("LOGINVIEW_RESTORE_PASSWORD_ALERT_SEND_EMAIL_BUTTON", comment: ""), action: { openURL(contactEmailURL) }),
                    .init(text: NSLocalizedString("LOGINVIEW_RESTORE_PASSWORD_ALERT_COPY_EMAIL_BUTTON", comment: ""), action: { UIPasteboard.general.string = Defaults[.hollowConfig]?.contactEmail ?? "" }),
                    .cancel
                ]
            )
            
        }
    }
}
