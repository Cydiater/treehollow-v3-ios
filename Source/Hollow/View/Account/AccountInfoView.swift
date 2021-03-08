//
//  AccountInfoView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Combine
import Defaults

struct AccountInfoView: View {
    @ObservedObject var viewModel = AccountInfoViewModel()
    var body: some View {
        List {
            Section {
                NavigationLink(NSLocalizedString("DEVICELISTVIEW_NAV_TITLE", comment: ""), destination: DeviceListView())
            }
            Section {
                NavigationLink(
                    NSLocalizedString("ACCOUNTINFOVIEW_CHANGE_PASSWORD_CELL_LABEL", comment: ""),
                    destination: ChangePasswordView().environmentObject(viewModel)
                )
            }
            Section {
                Button("ACCOUNTVIEW_LOGOUT_BUTTON", action: viewModel.logout)
                    .foregroundColor(.red)
            }
        }
        .defaultListStyle()
        .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
        .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
        .modifier(AppModelBehaviour(state: viewModel.appModelState))
        .disabled(viewModel.isLoading)
    }
}

extension AccountInfoView {
    struct ChangePasswordView: View {
        @EnvironmentObject var viewModel: AccountInfoViewModel
        @State private var email: String = ""
        @State private var originalPassword = ""
        @State private var newPassword = ""
        @State private var confirmedPassword = ""
        var contentInvalid: Bool {
            if viewModel.isLoading { return false }
            return originalPassword == "" ||
            newPassword == "" ||
            newPassword.count < 8 || newPassword.contains(" ") ||
            email == "" ||
            newPassword != confirmedPassword
        }
        var body: some View {
            List {
                Section {
                    TextField("CHANGEPASSWORDVIEW_ENTER_EMAIL_PLACEHOLDER", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                }
                
                SecureField("CHANGEPASSWORDVIEW_ENTER_ORI_PASSWORD_PLACEHOLDER", text: $originalPassword)

                Section(footer: Text("LOGINVIEW_PASSWORD_TEXTFIELD_REQUIREMENT_FOOTER").padding(.horizontal)) {
                    HStack {
                        SecureField("CHANGEPASSWORDVIEW_ENTER_NEW_PASSWORD_PLACEHOLDER", text: $newPassword)
                        if (newPassword.count < 8 && !newPassword.isEmpty) || newPassword.contains(" ") {
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .foregroundColor(.red)
                        }
                    }
                    HStack {
                        SecureField("CHANGEPASSWORDVIEW_CONFIRM_PASSWORD_PLACEHOLDER", text: $confirmedPassword)
                        if confirmedPassword != newPassword && confirmedPassword != "" {
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .foregroundColor(.red)
                        }
                    }
                }
                Button("CHANGEPASSWORDVIEW_SUBMMIT_BUTTON") {
                    viewModel.changePassword(for: email, original: originalPassword, new: newPassword)
                }
                .disabled(contentInvalid)
            }
            .defaultListStyle()
            .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
            .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
            .disabled(viewModel.isLoading)
        }
    }
}
