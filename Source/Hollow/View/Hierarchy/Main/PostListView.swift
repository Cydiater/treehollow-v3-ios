//
//  PostListView.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct PostListView: View {
    @Binding var postDataWrappers: [PostDataWrapper]
    @Binding var detailStore: HollowDetailStore?
    @Default(.blockedTags) var customBlockedTags
    @Default(.foldPredefinedTags) var foldPredefinedTags
    
    var revealFoldedTags = false
    var contentViewDisplayOptions: HollowContentView.DisplayOptions {
        var options: HollowContentView.DisplayOptions = [
            .compactText, .displayCitedPost, .displayImage, .displayVote
        ]
        if revealFoldedTags { options.insert(.revealFoldTags) }
        return options
    }
    var voteHandler: (Int, String) -> Void
    var starHandler: (Bool, Int) -> Void
    var imageReloadHandler: ((HollowImage) -> Void)?
    private let foldTags = Defaults[.hollowConfig]?.foldTags ?? []
    
    private let cardCornerRadius: CGFloat = UIDevice.isMac ? 17 : 13
    private let cardPadding: CGFloat? = UIDevice.isMac ? 25 : nil
    
    private func hideComments(for post: PostData) -> Bool {
        if revealFoldedTags { return false }
        if let tag = post.tag {
            if !foldPredefinedTags {
                return customBlockedTags.contains(tag)
            }
            return foldTags.contains(tag) || customBlockedTags.contains(tag)
        }
        return false
    }
    
    @ViewBuilder var body: some View {

        ForEach(postDataWrappers) { postDataWrapper in
            let post = postDataWrapper.post
            let shownReplyNumber = min(postDataWrapper.post.comments.count, 3)
            
            let hideComments = self.hideComments(for: post)
            VStack(spacing: UIDevice.isMac ? 25 : 15) {
                // TODO: Star actions
                HollowHeaderView(postData: post, compact: false, starAction: { starHandler($0, post.postId) }, disableAttention: false)
                HollowContentView(
                    postDataWrapper: postDataWrapper,
                    options: contentViewDisplayOptions,
                    voteHandler: { option in voteHandler(post.postId, option) },
                    imageReloadHandler: imageReloadHandler
                )
                // Check if comments exist to avoid additional spacing
                
                if post.replyNumber > 0, !hideComments {
                    VStack(spacing: 0) {
                        ForEach(post.comments.prefix(3)) { commentData in
                            HollowCommentContentView(commentData: .constant(commentData), compact: true, contentVerticalPadding: 10, postColorIndex: 0, postHash: 0)
                        }
                        if post.replyNumber > shownReplyNumber {
                            if post.comments.count == 0 {
                                Divider()
                                    .padding(.horizontal)
                            }

                            let text1 = shownReplyNumber == 0 ?
                                NSLocalizedString("TIMELINE_CARD_COMMENTS_COUNT_PREFIX_TOTAL", comment: "") :
                                NSLocalizedString("TIMELINE_CARD_COMMENTS_COUNT_PREFIX", comment: "")
                            let text2 = shownReplyNumber == 0 ?
                                NSLocalizedString("TIMELINE_CARD_COMMENTS_COUNT_SUFFIX_TOTAL", comment: "") :
                                NSLocalizedString("TIMELINE_CARD_COMMENTS_COUNT_SUFFIX", comment: "")
                            Text(text1 + "\(post.replyNumber - shownReplyNumber)" + text2)
                                .dynamicFont(size: 15).lineSpacing(post.comments.count == 0 ? 0 : 3)
                                
                                .foregroundColor(.uiColor(.secondaryLabel))
                                .padding(.top, 12)
                                .padding(.vertical, UIDevice.isMac ? 5 : 0)
                        }
                    }
                }
            }
            .padding(.bottom, post.replyNumber > shownReplyNumber && !hideComments ? 12 : cardPadding)
            .padding([.horizontal, .top], cardPadding)
            .background(Color.hollowCardBackground)
            .roundedCorner(cardCornerRadius)
            .fixedSize(horizontal: false, vertical: true)
            .defaultPadding(.bottom)
            .onClickGesture {
                guard let index = postDataWrappers.firstIndex(where: { $0.id == postDataWrapper.id }) else { return }
                IntegrationUtilities.conditionallyPresentDetail(store: HollowDetailStore(bindingPostWrapper: $postDataWrappers[index]))
            }
        }

    }
}
