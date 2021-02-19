//
//  WanderView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import WaterfallGrid

struct WanderView: View {
    @ObservedObject var viewModel: Wander = .init()
    
    var body: some View {
        CustomScrollView { _ in Group {
            WaterfallGrid((0..<viewModel.posts.count), id: \.self) { index in
                HollowWanderCardView(postData: $viewModel.posts[index])
            }
            .gridStyle(columnsInPortrait: 2, columnsInLandscape: 3, spacing: 10, animation: nil)
            .padding(.horizontal, 15)
            .background(Color.background)
            
            LoadingLabel()
                .padding(.vertical)
                .padding(.bottom)
        }}
    }
}

#if DEBUG
struct WanderView_Previews: PreviewProvider {
    static var previews: some View {
        WanderView()
    }
}
#endif
