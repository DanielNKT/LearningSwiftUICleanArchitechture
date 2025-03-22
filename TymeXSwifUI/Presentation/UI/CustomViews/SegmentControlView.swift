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
                Button {
                    selected = segment
                } label: {
                    VStack {
                        Text(segment)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(selected == segment ? .green : Color(uiColor: .systemGray))
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
                }
            }
        }
    }
}

struct TestSegmentedView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let segments: [String] = ["LIST", "GRID"]
    @State private var currentSegment = "LIST"

    // Keep both views alive
    private var listView: AnyView {
        return AnyView(coordinator.view(for: .listUser))
    }

    private var gridView: AnyView {
        return AnyView(coordinator.view(for: .gridUser))
    }

    var body: some View {
        VStack {
            SegmentedView(segments: segments, selected: $currentSegment)
                .padding(.top)

            Spacer(minLength: 16)

            ZStack {
                // Show both views, but control visibility
                listView
                    .opacity(currentSegment == "LIST" ? 1 : 0)
                    .allowsHitTesting(currentSegment == "LIST")

                gridView
                    .opacity(currentSegment == "GRID" ? 1 : 0)
                    .allowsHitTesting(currentSegment == "GRID")
            }
        }
    }
}
