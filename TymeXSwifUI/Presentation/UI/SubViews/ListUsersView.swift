//
//  TabbarView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 17/3/25.
//

import SwiftUI

struct ListUsersView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: HomeViewModel
    
    @State var since: Int = 0
    @State var perPage: Int = 20
    
    init(viewModel: HomeViewModel) {
        print("[DEBUG] --- ListUsersView init")
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading, viewModel.users.count == 0 {
                loadingView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.users.count == 0 {
                failedView(errorMessage)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.users, id: \.id) { user in
                            UserRow(user: user).listRowSeparator(.hidden)
                                .onTapGesture {
                                    coordinator.push(.detail(user.login ?? ""))
                                }
                                .id(user.id)
                        }
                        if viewModel.isLoading && viewModel.users.count > 0 {
                            ProgressView().padding()
                        }
                    }
                    .scrollTargetLayout()
                }
                .listStyle(.plain)
                .scrollPosition(id: $viewModel.activePhotoId, anchor: .bottomTrailing)
                .onChange(of: viewModel.activePhotoId, { oldValue, newValue in
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

private extension ListUsersView {
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
