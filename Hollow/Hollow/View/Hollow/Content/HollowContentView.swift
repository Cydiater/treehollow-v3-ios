//
//  HollowContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowContentView: View {
    var postDataWrapper: PostDataWrapper
    var compact: Bool
    var voteHandler: (String) -> Void
    var body: some View {
        if (postDataWrapper.post.type == .image || postDataWrapper.post.type == .vote) && postDataWrapper.post.hollowImage != nil {
            HollowImageView(hollowImage: postDataWrapper.post.hollowImage, description: postDataWrapper.post.text)
                .cornerRadius(4)
                .frame(maxHeight: 500)
                .fixedSize(horizontal: false, vertical: true)
        }
        
        if let citedPost = postDataWrapper.citedPost {
            HollowCiteContentView(postData: citedPost)
        }
        
        // Enable the context menu for the text if it is in detail view.
        if compact {
            textView()
        } else {
            textView()
                // Apply a transparent background to avoid
                // offset when presenting context menu
                .background(Color.clear)
                .contextMenu(compact ? nil : ContextMenu(menuItems: {
                    Button("Copy full text", action: {
                        UIPasteboard.general.string = postDataWrapper.post.text
                    })
                }))
        }
                
        if postDataWrapper.post.type == .vote {
            HollowVoteContentView(vote: postDataWrapper.post.vote!, voteHandler: voteHandler)
        }

    }
    
    private func textView() -> some View {
        HollowTextView(text: postDataWrapper.post.text, compactLineLimit: compact ? 6 : nil)
    }
}

#if DEBUG
struct HollowContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(testPostWrappers) { postDataWrapper in
                HollowContentView(postDataWrapper: postDataWrapper, compact: false, voteHandler: {_ in})
                    .background(Color.background)
            }
        }
    }
}
#endif
