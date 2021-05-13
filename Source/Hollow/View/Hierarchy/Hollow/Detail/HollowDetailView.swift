//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

struct HollowDetailView: View {
    @ObservedObject var store: HollowDetailStore
    
    var showHeader = true
    @State private var headerFrame: CGRect = .zero
    @State private var commentViewFrame: CGRect = .zero
    @State var inputPresented = false
    @State var jumpedToIndex: Int?
    @State var jumpedIndexFromComment: Int?
    @State private var showHeaderContent = Defaults[.useListInDetail]
    @State var reverseComments = false
    @State var showOnlyName: String?
    
    private let scrollToAnchor = UnitPoint(x: 0.5, y: 0.1)
    let scrollAnimation = Animation.easeInOut(duration: 0.25)
    
    @ScaledMetric(wrappedValue: 10) var headerVerticalPadding: CGFloat
    @ScaledMetric(wrappedValue: 16) var newCommentLabelSize: CGFloat
    @ScaledMetric var commentViewBottomPadding: CGFloat = 100
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @Default(.useListInDetail) var useListInDetail
    
    var body: some View {
        VStack(spacing: 0) {
            if showHeader {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: dismissSelf) {
                            Image(systemName: "xmark")
                                .modifier(ImageButtonModifier())
                                .padding(.trailing, 5)
                        }
                        .padding(.trailing, 5)
                        
                        _HollowHeaderView(
                            postData: store.postDataWrapper.post,
                            compact: false,
                            // Show text on header when the text is not visible
                            showContent: showHeaderContent,
                            starAction: store.star,
                            isLoading: store.isLoading,
                            disableAttention: store.isEditingAttention || store.isLoading,
                            menuContent: { Group {
                                Button(action: store.requestDetail) {
                                    Label("DETAIL_MENU_REFRESH_LABEL", systemImage: "arrow.clockwise")
                                }
                                .disabled(store.isLoading)
                                
                                Divider()
                                
                                Button(action: {
                                    let inputStore = HollowInputStore(presented: .constant(true), selfDismiss: true, refreshHandler: nil)
                                    inputStore.text = "#\(store.postDataWrapper.post.postId.string)\n"
                                    IntegrationUtilities.presentView(modalInPresentation: true, content: { HollowInputView(inputStore: inputStore) })
                                }) {
                                    Label("DETAIL_MENU_QUOTE_LABEL", systemImage: "text.quote")
                                }
                                
                                Divider()
                                
                                ReportMenuContent(
                                    store: store,
                                    permissions: store.postDataWrapper.post.permissions,
                                    commentId: nil
                                )
                                .disabled(store.isLoading)
                            }}
                        )
                        .onTapGesture(count: 2, perform: store.requestDetail)
                        .disabled(store.noSuchPost)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, headerVerticalPadding)
                    Divider()
                }
            }
            
            if useListInDetail {
                List {
                    content
                        .listRowInsets(EdgeInsets())
                        .background(Color.hollowCardBackground)
                }
                .buttonStyle(BorderlessButtonStyle())

            } else {
                ScrollView { ScrollViewReader { proxy in
                    LazyVStack(spacing: 0) {
                        content
                    }
                    .onChange(of: store.replyToIndex) { index in
                        withAnimation(scrollAnimation) {
                            proxy.scrollTo(index, anchor: scrollToAnchor)
                        }
                    }
                    .onChange(of: jumpedIndexFromComment) { index in
                        if index != nil {
                            withAnimation(scrollAnimation) {
                                jumpedIndexFromComment = nil
                                proxy.scrollTo(index, anchor: scrollToAnchor)
                                jumpedToIndex = index
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(scrollAnimation) { jumpedToIndex = nil }
                            }
                        }
                    }
                    // Jump to certain comment
                    .onChange(of: store.isLoading) { loading in
                        if !loading {
                            // Check if there is any comment to jump to
                            // when finish loading
                            if let jumpToCommentId = store.jumpToCommentId {
                                if let index = store.postDataWrapper.post.comments.firstIndex(where: { $0.commentId == jumpToCommentId }) {
                                    withAnimation(scrollAnimation) {
                                        proxy.scrollTo(index, anchor: scrollToAnchor)
                                        jumpedToIndex = index
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation(scrollAnimation) { jumpedToIndex = nil }
                                    }
                                }
                                store.jumpToCommentId = nil
                            }
                        }
                    }
                    
                }}
                .coordinateSpace(name: "detail.scrollview")
            }
            
        }
        
        .padding([.horizontal, .bottom], UIDevice.isMac ? ViewConstants.macAdditionalPadding : 0)
        .padding(.top, UIDevice.isMac ? 10 : 0)
        .edgesIgnoringSafeArea(.bottom)
        .disabled(store.noSuchPost)
        
        .background(Color.hollowCardBackground.ignoresSafeArea())
        
        .overlay(Group { if store.replyToIndex < -1 && !store.noSuchPost {
            FloatButton(
                action: {
                    withAnimation(scrollAnimation) { store.replyToIndex = -1 }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                },
                systemImageName: "text.bubble.fill",
                imageScaleFactor: 0.8
            )
            .edgesIgnoringSafeArea(.bottom)
            .bottom()
            .trailing()
            .padding()
            .padding(7)
            .padding(.bottom, 7)
            .disabled(store.isSendingComment || store.isLoading)
        }})
        .edgesIgnoringSafeArea(.bottom)
        
        .overlay(Group { if store.replyToIndex >= -1 {
            let post = store.postDataWrapper.post
            let name = store.replyToIndex == -1 ?
                NSLocalizedString("COMMENT_INPUT_REPLY_POST_SUFFIX", comment: "") :
                post.comments[store.replyToIndex].name
            HollowCommentInputView(
                store: store,
                transitionAnimation: scrollAnimation,
                replyToName: name
            )
            .edgesIgnoringSafeArea([])
            .bottom()
            .transition(.move(edge: .bottom))
            
        }})
        
        .onChange(of: store.replyToIndex) { index in
            if index >= -1 {
                withAnimation(scrollAnimation) { inputPresented = true }
            }
        }
        .onChange(of: inputPresented) { presented in
            if !presented { withAnimation(scrollAnimation) { store.replyToIndex = -2 }}
        }
        
        .onDisappear {
            store.bindingCancellable?.cancel()
        }
        
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
        
    }
}

extension HollowDetailView {
    
    @ViewBuilder var content: some View {
        
        if useListInDetail {
            VStack(spacing: 0) {
                mainContent
            }
        } else {
            mainContent
        }
        
        if !store.noSuchPost {
            commentView
                .listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder var mainContent: some View {
        let spacing: CGFloat = UIDevice.isMac ? 20 : 13
        
        Spacer(minLength: 5).fixedSize()
            .background(Color.hollowCardBackground)
        
        if store.noSuchPost {
            Text("DETAILVIEW_NO_SUCH_POST_PLACEHOLDER")
                .padding(.top, spacing)
                .padding(.horizontal)
                .modifier(HollowTextView.TextModifier(inDetail: true))
            
        } else {
            HollowContentView(
                postDataWrapper: store.postDataWrapper,
                options: [.displayVote, .displayImage, .displayCitedPost, .revealFoldTags, .showHyperlinks],
                voteHandler: store.vote,
                imageReloadHandler: { _ in store.loadPostImage() }
            )
            .padding(.top, spacing)
            .padding(.horizontal)
            .id(-1)
        }
        
        Spacer(minLength: spacing * 2).fixedSize()
            // Get the frame in the scroll view content
            .modifier(GetFrame(coordinateSpace: .named("detail.scrollview"), handler: { frame in
                guard showHeader && !useListInDetail else { return }
                if frame.maxY > 0 && showHeaderContent { withAnimation { showHeaderContent = false }}
                if frame.maxY <= 0 && !showHeaderContent { withAnimation { showHeaderContent = true }}
            }))
    }
}

extension HollowDetailView {
    @ViewBuilder static func conditionalDetailView(store: HollowDetailStore, push: Bool = UIDevice.isPad) -> some View {
        if push {
            HollowDetailView_iPad(store: store)
        } else {
            HollowDetailView(store: store)
        }
    }
}
