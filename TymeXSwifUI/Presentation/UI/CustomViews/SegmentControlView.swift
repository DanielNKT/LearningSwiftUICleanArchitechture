//
//  SegmentControlView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 22/3/25.
//

import SwiftUI

struct SegmentedView: View {
    let segments: [String]
    @Binding var selected: String

    @Namespace var name

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.self) { segment in
                VStack(spacing: 4) {
                    Text(segment)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(selected == segment ? .green : .gray)

                    ZStack {
                        Capsule()
                            .fill(Color.clear)
                            .frame(height: 4)
                        if selected == segment {
                            Capsule()
                                .fill(Color.green)
                                .frame(height: 4)
                                .matchedGeometryEffect(id: "Tab", in: name)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle()) // Make entire area tappable
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selected = segment
                    }
                }
            }
        }
    }
}

struct TabbarItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String
}

struct CustomTabbarView: View {
    let tabbarItems: [ProfileTab]
    @Binding var selectedItem: ProfileTab
    
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack {
            ForEach(tabbarItems) { item in
                VStack(spacing: 4) {
                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .fontWeight(.medium)
                        .foregroundColor(selectedItem == item ? .green : .gray)

                    ZStack {
                        Capsule()
                            .fill(Color.clear)
                            .frame(height: 4)
                        if selectedItem == item {
                            Capsule()
                                .fill(Color.green)
                                .frame(height: 4)
                                .matchedGeometryEffect(id: "Tab", in: animationNamespace)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedItem = item
                    }
                }
            }
        }.background(Color.white)
    }
}

