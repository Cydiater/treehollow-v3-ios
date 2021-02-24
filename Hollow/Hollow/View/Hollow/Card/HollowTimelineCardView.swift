//
//  HollowTimelineCardView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowTimelineCardView: View {
    @Binding var postDataWrapper: PostDataWrapper
    @ObservedObject var viewModel: HollowTimelineCard
    
    var body: some View {
        VStack(spacing: 15) {
            // TODO: Star actions
            HollowHeaderView(postData: postDataWrapper.post, compact: false)
            HollowContentView(
                postDataWrapper: postDataWrapper,
                options: [.compactText, .displayCitedPost, .displayImage, .displayVote],
                voteHandler: viewModel.voteHandler
            )
            // Check if comments exist to avoid additional spacing
            if postDataWrapper.post.comments.count > 0 {
                CommentView(postData: $postDataWrapper.post)
            }
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(10)
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu(ContextMenu(menuItems: {
            Section {
                Button(action: {

                }) {
                    Label("Report", systemImage: "exclamationmark")
                }
            }
        }))
    }
    
    private struct CommentView: View {
        @Binding var postData: PostData
        /// Max comments to be displayed in the timeline card.
        @State private var maxCommentCount = 3
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(postData.comments.indices.prefix(maxCommentCount), id: \.self) { index in
                    HollowCommentContentView(commentData: $postData.comments[index], compact: true, contentVerticalPadding: 10)
                }
                if postData.replyNumber > maxCommentCount {
                    // FIXME: How to localize this stuff??
                    Text("还有 \(postData.replyNumber - maxCommentCount) 条评论")
                        .font(.system(size: body15)).lineSpacing(3)

                    .foregroundColor(.uiColor(.secondaryLabel))
                    .padding(.top)
                }
            }
        }
    }
}

#if DEBUG
struct HollowTimelineCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HollowTimelineCardView(postDataWrapper: .constant(testPostWrappers[1]), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
            HollowTimelineCardView(postDataWrapper: .constant(testPostWrappers[1]), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
                .colorScheme(.dark)
        }
    }
}
#endif
