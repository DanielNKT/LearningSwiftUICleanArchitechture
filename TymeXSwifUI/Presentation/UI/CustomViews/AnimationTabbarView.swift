//
//  AnimationTabbarView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 23/5/25.
//

import SwiftUI

struct AnimationTabbarView: View {
    var tint: Color = Color.blue
    var inactiveTint: Color = Color.gray
    
    @Binding var selectedTab: Tab
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabItem(tint: tint,
                        inactiveTint: inactiveTint,
                        tab: tab,
                        animation: animation,
                        activeTab: $selectedTab,
                        position: $tabShapePosition)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            TabShape(midPoint: tabShapePosition.x)
                .fill(Color.white)
                .ignoresSafeArea()
                .padding(.top, 25)
                .shadow(color: tint.opacity(0.2), radius: 5, x: 0, y: -5)
        )
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: selectedTab)
    }
}

struct TabItem: View {
    var tint: Color
    var inactiveTint: Color
    var tab: Tab
    var animation: Namespace.ID
    @Binding var activeTab: Tab
    @Binding var position: CGPoint
    
    /// Get Tab Item Position on the Screen
    @State private var tabPosition: CGPoint = .zero
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: tab.systemImage)
                .foregroundColor(activeTab == tab ? .white : inactiveTint)
                .frame(width: activeTab == tab ? 48 : 32, height: activeTab == tab ? 48 : 32)
                .background {
                    if activeTab == tab {
                        Circle().fill(tint.gradient)
                            .matchedGeometryEffect(id: "ActiveTab", in: animation)
                    }
                }
            
            Text(tab.rawValue)
                .foregroundColor(activeTab == tab ? tint : inactiveTint)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .viewPositionOnScreen(completion: { rect in
            tabPosition.x = rect.midX
            if activeTab == tab {
                position.x = rect.midX
            }
        })
        .onTapGesture {
            activeTab = tab
            
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                position.x = tabPosition.x
            }
        }
    }
    
}
