//
//  MessageView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct MessageView: View {
    @Binding var presented: Bool
    @State private var page: Page = .message
    @ObservedObject var messageStore = MessageStore()
    @ObservedObject var postListStore = PostListRequestStore(type: .attentionList)
    @State var detailStore: HollowDetailStore?
    @State private var isSearching = false
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            topBar
            if page == .message {
                systemMessageView
            } else if page == .attention {
                attentionListView
            }
        }
        .defaultBlurBackground(hasPost: true)
        .overlay(Group { if isSearching {
            SearchView(
                presented: $isSearching,
                store: .init(type: .attentionListSearch, options: [.unordered]),
                showAdvancedOptions: false
            )
        }})
    }
}

extension MessageView {
    var topBar: some View {
        HStack {
            Button(action: { withAnimation { presented = false } }) {
                Image(systemName: "xmark")
                    .modifier(ImageButtonModifier())
                    .padding(.trailing)
            }
            Picker("", selection: $page) {
                Text(NSLocalizedString("MESSAGEVIEW_PICKER_MESSAGE", comment: ""))
                    .tag(Page.message)
                Text(NSLocalizedString("MESSAGEVIEW_PICKER_ATTENTION", comment: ""))
                    .tag(Page.attention)
            }
            .padding(.horizontal)
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }
        .padding(.horizontal)
        .topBar()
        .padding(.bottom, 5)

    }
    
    var systemMessageView: some View {
        CustomScrollView(refresh: {_ in}) { proxy in VStack(spacing: 0) {
            ForEach(messageStore.messages) { message in
                VStack(alignment: .leading) {
                    HStack {
                        Text(message.title)
                            .bold()
                            .foregroundColor(.hollowContentText)
                        Spacer()
                        Text(HollowDateFormatter(date: message.timestamp).formattedString())
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                    .padding(.bottom, 7)
                    Text(message.content)
                }
                .padding()
                .background(Color.hollowCardBackground)
                .cornerRadius(15)
            }
            .padding(.top)
        }}
        .ignoresSafeArea()
        .padding(.horizontal)
        .modifier(ErrorAlert(errorMessage: $messageStore.errorMessage))
        .modifier(LoadingIndicator(isLoading: postListStore.isLoading))
        .modifier(AppModelBehaviour(state: messageStore.appModelState))
    }
    
    var attentionListView: some View {
        CustomScrollView(
            didScrollToBottom: postListStore.loadMorePosts,
            refresh: postListStore.refresh
        ) { proxy in
            VStack(spacing: 0) {
                SearchBar(isSearching: $isSearching)
                    .padding(.bottom)

                PostListView(
                    postDataWrappers: $postListStore.posts,
                    detailStore: $detailStore,
                    voteHandler: postListStore.vote,
                    starHandler: postListStore.star
                )
            }
        }
        .padding(.horizontal)
        .ignoresSafeArea()
        .background(Color.background)
        .modifier(AppModelBehaviour(state: postListStore.appModelState))
        .modifier(LoadingIndicator(isLoading: postListStore.isLoading))
        .modifier(ErrorAlert(errorMessage: $postListStore.errorMessage))
    }
}

extension MessageView {
    enum Page: Int, Hashable { case message, attention }
}
