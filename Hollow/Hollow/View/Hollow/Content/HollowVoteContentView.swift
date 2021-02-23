//
//  HollowVoteContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowVoteContentView: View {
    var vote: VoteData
    var voteHandler: (String) -> Void
    
    @State private var selectedButNotFinishIndex: Int = -1
    
    var body: some View {
        VStack(spacing: 10) {
            // The count of the options will not change, so we just use the count here.
            ForEach(vote.voteData.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        withAnimation(.default) {
                            selectedButNotFinishIndex = index
                            voteHandler(vote.voteData[index].title)
                        }
                    }) {
                        VoteBarView(voteData: vote.voteData[index], selectedButNotFinish: selectedButNotFinishIndex == index, selected: vote.votedOption == vote.voteData[index].title)
                    }
                    // Disable the button when the user has voted
                    .disabled(vote.voteData[index].voteCount >= 0 || selectedButNotFinishIndex != -1)
                }
            }
        }
    }
    
    // TODO: Vote proportion
    private struct VoteBarView: View {
        var voteData: VoteData.Data
        private var voted: Bool { voteData.voteCount >= 0 }
        var selectedButNotFinish: Bool
        var selected: Bool
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat

        var body: some View {
            HStack {
                Text(voteData.title)
                    .layoutPriority(0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                if selected {
                    Image(systemName: "checkmark")
                        .layoutPriority(0.1)
                }
                Spacer()
                // Not displaying the vote result if not voted
                if voted {
                    Text("\(voteData.voteCount)").bold()
                        .layoutPriority(1)
                    Text(LocalizedStringKey("votes"))
                        .layoutPriority(0.9)
                }
                // Show spinner when submitting vote option
                if !voted && selectedButNotFinish {
                    Spinner(color: .hollowContentText, desiredWidth: 14)
                        .layoutPriority(1)
                }
            }
            .font(.system(size: body15))
            .lineLimit(1)
            .foregroundColor(selected ? .white : .uiColor(.label))
            .padding(10)
            .padding(.horizontal, 8)
            .background(
                LinearGradient.vertical(gradient: selected ? .hollowContentVote : .clear)
            )
            .overlay(
                Group {
                    if !selected {
                        LinearGradient.vertical(gradient: .hollowContentVote)
                            .clipShape(Capsule().stroke(style: .init(lineWidth: 3)))
                    }
                }
            )
            .clipShape(Capsule())
        }
    }
    
    //    private struct VotePortionRectangle: Shape {
    //        var proportion: Double
    //        func path(in rect: CGRect) -> Path {
    //            let endX = rect.minX + rect.width * CGFloat(proportion)
    //            let minY = rect.minY + 0 * rect.height
    //            let firstPoint = CGPoint(x: rect.minX, y: minY)
    //            let secondPoint = CGPoint(x: endX, y: minY)
    //            let thirdPoint = CGPoint(x: endX, y: rect.maxY)
    //            let fourthPoint = CGPoint(x: rect.minX, y: rect.maxY)
    //
    //            return Path { path in
    //                path.move(to: firstPoint)
    //                path.addLine(to: secondPoint)
    //                path.addLine(to: thirdPoint)
    //                path.addLine(to: fourthPoint)
    //                path.addLine(to: firstPoint)
    //            }
    //        }
    //    }
}

#if DEBUG
struct HollowVoteContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowVoteContentView(vote: .init(votedOption: nil, voteData: [.init(title: "赞成", voteCount: -1), .init(title: "反对", voteCount: -1)]), voteHandler: { string in print("Selected option \(string)") })
            .background(Color.black)
            .colorScheme(.dark)
    }
}
#endif
