//
//  HollowDetailSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension HollowDetailView {
    @ViewBuilder var commentView: some View {
        let postData = store.postDataWrapper.post

        HStack {
            (Text("\(postData.replyNumber) ") + Text("HOLLOWDETAIL_COMMENTS_COUNT_LABEL_SUFFIX"))
                .fontWeight(.heavy)
            Spacer()
            Button(action: {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                store.replyToIndex = -1
            }) {
                Text("HOLLOWDETAIL_COMMENTS_NEW_COMMENT_BUTTON")
                    .fontWeight(.medium)
                    .font(.system(size: newCommentLabelSize))
                    .lineLimit(1)
            }
            .accentColor(.hollowContentVoteGradient1)
        }
        .padding(.top)
        .padding(.bottom, 5)

        if postData.comments.count > 30 {
            LazyVStack {
                ForEach(postData.comments.indices, id: \.self) { index in
                    commentView(at: index)
                    .id(postData.comments[index].commentId)
                }
            }
        } else {
            VStack {
                ForEach(postData.comments.indices, id: \.self) { index in
                    commentView(at: index)
                    .id(postData.comments[index].commentId)
                }
            }

        }
        if store.isLoading {
            LoadingLabel(foregroundColor: .primary).leading()
        }
    }
    
    func commentView(at index: Int) -> some View {
        let hideLabel: Bool
        let comment = store.postDataWrapper.post.comments[index]
        if index == 0 { hideLabel = false }
        else { hideLabel = comment.name == store.postDataWrapper.post.comments[index - 1].name }
        return HollowCommentContentView(commentData: $store.postDataWrapper.post.comments[index], compact: false, hideLabel: hideLabel, imageReloadHandler: { store.reloadImage($0, commentId: comment.commentId) })
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .background(
                Group {
                    store.replyToIndex == index || jumpedToIndex == index ?
                        Color.background : nil
                }
                .roundedCorner(10)
                .animation(.none)
            )
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                store.replyToIndex = index
                jumpedToIndex = nil
            }
            .contextMenu {
                if comment.text != "" {
                    Button(action: {
                        UIPasteboard.general.string = comment.text
                    }, label: {
                        Label(NSLocalizedString("COMMENT_VIEW_COPY_TEXT_LABEL", comment: ""), systemImage: "plus.square.on.square")
                    })
                    Divider()
                }
                let links = Array(comment.text.links().compactMap({ URL(string: $0) }))
                let citedPosts = comment.text.citationNumbers()
                if !links.isEmpty { Divider() }
                ForEach(links, id: \.self) { link in
                    Button(link.absoluteString, action: { openURL(link) })
                }
                if !links.isEmpty { Divider() }
                ForEach(citedPosts, id: \.self) { post in
                    let wrapper = PostDataWrapper.templatePost(for: post)
                    Button(post.string, action: {
                        presentView {
                            HollowDetailView(store: .init(bindingPostWrapper: .constant(wrapper)))
                        }
                    })
                }
                if !citedPosts.isEmpty { Divider() }
                ReportMenuContent(
                    store: store,
                    data: \.postDataWrapper.post.comments[index].permissions,
                    commentId: comment.commentId
                )
            }
    }

}
