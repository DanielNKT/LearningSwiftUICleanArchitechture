//
//  Home.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 4/3/25.
//
import SwiftUI

struct Home: View {
    @State private var path = NavigationPath()
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView()
            } else if let errorMessage = viewModel.errorMessage {
                failedView(errorMessage)
            } else {
                NavigationStack(path: $path)  {
                    List(viewModel.users) { user in
                        UserRow(user: user).listRowSeparator(.hidden)
                            .onTapGesture {
                                path.append(user)
                            }
                    }
                    .listStyle(.plain)
                    .navigationDestination(for: String.self) { item in
                        UserDetail()
                    }
                    .navigationTitle("Github Users")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .onAppear {
//                    Task {
//                        await viewModel.fetchUsers()
//                    }
                    if !viewModel.hasLoaded {
                        viewModel.fetchUsers()
                        viewModel.hasLoaded = true
                    }
                    
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
//            Task {
//                await viewModel.fetchUsers()
//            }
            viewModel.fetchUsers()
        })
    }
}
