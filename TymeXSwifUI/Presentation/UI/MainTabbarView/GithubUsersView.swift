//
//  ListUsersView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 23/5/25.
//

import SwiftUI

struct GithubUsersView: View {
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
