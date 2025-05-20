//
//  ChipsView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 20/5/25.
//

import SwiftUI

struct TagsView<Content: View, Tag: Equatable>: View where Tag: Hashable {
    var tags: [Tag]
    var canCheck: Bool = false
    var selectedAll: Bool = false
    var spacing: CGFloat = 10
    var animation: Animation = .easeInOut(duration: 0.2)
    
    @ViewBuilder var content: (Tag, Bool) -> Content
    var didChangeSelection: ([Tag]) -> Void
    @State private var selectedTags: [Tag] = []
    
    var body: some View {
        CustomTagLayout(spacing: spacing) {
            ForEach(tags, id: \.self) { tag in
                content(tag, selectedTags.contains(tag))
                    .contentShape(.rect)
                    .onTapGesture {
                        if canCheck == false { return }
                        withAnimation(animation) {
                            if selectedTags.contains(tag) {
                                selectedTags.removeAll(where: { $0 == tag })
                            } else {
                                selectedTags.append(tag)
                            }
                        }
                        
                        ///Callback after update
                        didChangeSelection(selectedTags)
                    }
                    .onAppear {
                        if selectedAll {
                            selectedTags = tags
                        }
                    }
            }
        }
    }
}

fileprivate struct CustomTagLayout: Layout {
    var spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        return .init(width: width, height: maxHeight(proposal: proposal, subviews: subviews))
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        
        for subview in subviews {
            let fitSize = subview.sizeThatFits(proposal)
            
            if (origin.x + fitSize.width) > bounds.maxX {
                origin.x = bounds.minX
                origin.y += fitSize.height + spacing
                subview.place(at: origin, proposal: proposal)
                origin.x += fitSize.width + spacing
            } else {
                subview.place(at: origin, proposal: proposal)
                origin.x += fitSize.width + spacing
            }
        }
    }
    
    private func maxHeight(proposal: ProposedViewSize, subviews: Subviews) -> CGFloat {
        var origin: CGPoint = .zero
        for subview in subviews {
            let fitSize = subview.sizeThatFits(proposal)
            
            if (origin.x + fitSize.width) > (proposal.width ?? 0){
                origin.x = 0
                origin.y += fitSize.height + spacing
                origin.x += fitSize.width + spacing
            } else {
                origin.x += fitSize.width + spacing
            }
            
            if subview == subviews.last {
                origin.y += fitSize.height
            }
        }
        return origin.y
    }
}

struct TagsSelectionView: View {
    var tags: [String]
    var selectedAll: Bool = false
    var canCheck: Bool = false
    
    var didChangeSelection: (([String]) -> Void)? = nil
    
    var body: some View {
            VStack {
                TagsView(tags: tags, canCheck: canCheck, selectedAll: selectedAll, spacing: 4) { tag, isSelected in
                    /// Your Custom View
                    TagView(tag, isSelected: isSelected)
                } didChangeSelection: { selection in
                    print(selection)
                    didChangeSelection?(selection)
                }
                .padding(10)
                .background(.gray.opacity(0.1), in: .rect(cornerRadius: 20))
            }
    }
    
    /// Setup UI for Tag View
    @ViewBuilder
    func TagView(_ tag: String, isSelected: Bool) -> some View {
        HStack(spacing: 10) {
            Text(tag)
                .font(.callout)
                .foregroundStyle(isSelected ? .white : .primary)
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            ZStack {
                Capsule()
                    .fill(.background)
                    .opacity(!isSelected ? 1 : 0)
                
                Capsule()
                    .fill(.green.gradient)
                    .opacity(isSelected ? 1 : 0)
            }
        }
    }
}

#Preview {
    TagsSelectionView(tags: ["C++", "Objective-C", "Swift", "SwiftUI", "Combine", "RxSwift"])
}
