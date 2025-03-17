//
//  GridUsersView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 17/3/25.
//

import SwiftUI

struct GridUsersView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: HomeViewModel
    
    @State var since: Int = 0
    @State var perPage: Int = 20
    
    /// Pagination properties
    @State private var activePhotoId: Int?
    @State private var lastPhotoId: Int?
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            NavigationStack(path: $coordinator.path)  {
                if viewModel.isLoading, viewModel.users.count == 0 {
                    loadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.users.count == 0 {
                    failedView(errorMessage)
                } else {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing: 16), count: 2), spacing: 16) {
                            ForEach(viewModel.users, id: \.id) { user in
                                PhotoCardView(user: user)
                                    .onTapGesture {
                                        coordinator.push(.detail(user.login ?? ""))
                                    }
                            }
                            if viewModel.isLoading && viewModel.users.count > 0 {
                                ProgressView().padding()
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .listStyle(.plain)
                    .scrollPosition(id: $activePhotoId, anchor: .bottomTrailing)
                    .onChange(of: activePhotoId, { oldValue, newValue in
                        if newValue == viewModel.lastUserId, !viewModel.isLoading {
                            viewModel.fetchUsers()
                        }
                    })
                    .onAppear {
                        if viewModel.users.isEmpty {
                            viewModel.fetchUsers()
                        }
                    }
                    .contentMargins(16.0)
                }
            }
        }
    }
}

private extension GridUsersView {
    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    func failedView(_ errorMessage: String) -> some View {
        ErrorView(errorMessage: errorMessage, retryAction: {
            viewModel.fetchUsers()
        })
    }
}
