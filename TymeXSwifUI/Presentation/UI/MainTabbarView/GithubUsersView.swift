//
//  ListUsersView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 23/5/25.
//

import SwiftUI

/// Enum định nghĩa các segment
enum UserSegment: String, CaseIterable, Hashable {
    case list = "LIST"
    case grid = "GRID"
}

struct GithubUsersView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    @ObservedObject var viewModel: GithubUsersViewModel
    
    @State private var listView: AnyView? = nil
    @State private var gridView: AnyView? = nil

    var body: some View {
        VStack {
            SegmentedView(
                segments: UserSegment.allCases.map(\.rawValue),
                selected: Binding<String>(
                    get: { viewModel.currentSegment.rawValue },
                    set: { raw in
                        if let newSegment = UserSegment(rawValue: raw) {
                            viewModel.currentSegment = newSegment
                        }
                    }
                )
            )
            .padding(.top)

            Spacer(minLength: 16)

            cachedView
        }
        .onChange(of: viewModel.currentSegment) { oldSegment, newSegment in
            cacheIfNeeded(for: newSegment)
        }
        .onAppear {
            cacheIfNeeded(for: viewModel.currentSegment)
        }
    }

    private var cachedView: some View {
        switch viewModel.currentSegment {
        case .list:
            return listView ?? AnyView(EmptyView())
        case .grid:
            return gridView ?? AnyView(EmptyView())
        }
    }

    private func cacheIfNeeded(for segment: UserSegment) {
        switch segment {
        case .list:
            if listView == nil {
                listView = AnyView(coordinator.view(for: .listUser))
            }
        case .grid:
            if gridView == nil {
                gridView = AnyView(coordinator.view(for: .gridUser))
            }
        }
    }
}


