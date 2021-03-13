//
//  DeviceListView.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject var deviceListStore = DeviceListStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(deviceListStore.deviceData.devices, id: \.deviceUUID) { device in
                    DeviceCardView(
                        device: device,
                        isCurrentDevice:
                            deviceListStore.deviceData.thisDeviceUUID ==
                            device.deviceUUID,
                        isLoggingout:
                            deviceListStore.loggingoutUUID ==
                            device.deviceUUID,
                        logoutAction: deviceListStore.logout
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    .disabled(deviceListStore.isLoading)
                }
                
                // Placeholder
                Spacer().horizontalCenter()
            }
            .padding(.bottom)
        }
        .background(Color.background.ignoresSafeArea())
        .navigationBarTitle(NSLocalizedString("DEVICELISTVIEW_NAV_TITLE", comment: ""), displayMode: .large)
        .modifier(LoadingIndicator(isLoading: deviceListStore.isLoading))
        .modifier(ErrorAlert(errorMessage: $deviceListStore.errorMessage))
        .navigationBarItems(trailing: Button(action: deviceListStore.requestDeviceList) {
            Image(systemName: "arrow.clockwise")
        })
        .modifier(AppModelBehaviour(state: deviceListStore.appModelState))
        .imageScale(.medium)
        .onAppear { deviceListStore.requestDeviceList() }
    }
}

extension DeviceListView {
    private struct DeviceCardView: View {
        @State private var alertPresented: Bool = false

        var device: DeviceInformationType
        var isCurrentDevice: Bool
        var isLoggingout: Bool
        var logoutAction: (String) -> Void
        
//        @State private var alertPresented = false
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
        @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
        @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
        @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize
        
        var body: some View {
            VStack(alignment: .leading, spacing: body14) {
                let deviceLocalized = NSLocalizedString("DEVICELIST_CARD_DEVICE_TITLE", comment: "")
                let currentLocalized = NSLocalizedString("DEVICELIST_CARD_DEVICE_TITLE_CURRENT", comment: "")
                section(header: deviceLocalized + (isCurrentDevice ? " " + currentLocalized : ""), content: device.deviceInfo)
                
                HStack(alignment: .bottom) {
                    section(header: NSLocalizedString("DEVICELIST_CARD_LOGIN_DATE_TITLE", comment: ""), content: String(device.loginDate.description.prefix(10)))
                    Spacer()
                    
                    // We won't allow the user to terminate the current
                    // device in device list.
                    if !isCurrentDevice {
                        MyButton(
                            action: { alertPresented = true },
                            gradient: .vertical(gradient: .button),
                            transitionAnimation: .default) {
                            Group {
                                if isLoggingout {
                                    let processingText = NSLocalizedString("DEVICELIST_CARD_BUTTON_PROCESSING", comment: "")
                                    Text(processingText + "...")
                                } else {
                                    Text("DEVICELIST_CARD_BUTTON_LOGOUT")
                                }
                            }
                            .font(.system(size: buttonFontSize, weight: .bold))
                            .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding()
            .background(
                Color.hollowCardBackground.overlay(
                    Text(device.deviceType.description)
                        .fontWeight(.semibold)
                        .font(.system(.title, design: .monospaced))
                        .foregroundColor(.uiColor(.systemFill))
                        .padding(.top)
                        .padding(.trailing)
                        .trailing()
                        .top()
                )
            )
            .roundedCorner(15)
            
            .styledAlert(
                presented: $alertPresented,
                title: NSLocalizedString("DEVICE_LIST_LOGOUT_ALERT_TITLE", comment: ""),
                message: "\(device.deviceInfo)",
                buttons: [
                .init(text: NSLocalizedString("DEVICE_LIST_LOGOUT_ALERT_CONFIRM_BUTTON", comment: ""), style: .destructive, action: { logoutAction(device.deviceUUID) }),
                .cancel
            ])
        }
        
        private func section(header: String, content: String) -> some View {
            VStack(alignment: .leading, spacing: body5) {
                Text(header.uppercased())
                    .font(.system(size: body15, weight: .semibold))
                    .foregroundColor(.hollowContentText)
                Text(content)
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}

#if DEBUG
struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
        //            .background(Color.background)
        //            .colorScheme(.dark)
    }
}
#endif
