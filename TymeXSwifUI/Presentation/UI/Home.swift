//
//  Home.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 4/3/25.
//
import SwiftUI

struct Home: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: HomeViewModel
    
    @State var since: Int = 0
    @State var perPage: Int = 20
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            NavigationStack(path: $coordinator.path)  {
                if viewModel.isLoading {
                    loadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    failedView(errorMessage)
                } else {
                    List(viewModel.users) { user in
                        UserRow(user: user).listRowSeparator(.hidden)
                            .onTapGesture {
                                coordinator.push(.detail(user.login ?? ""))
                            }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Github Users")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.users.isEmpty {
                    viewModel.fetchUsers()
                }
            }
        }
    }
}

private extension Home {
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
