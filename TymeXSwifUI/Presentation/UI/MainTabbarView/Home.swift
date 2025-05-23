//
//  Home.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 4/3/25.
//
import SwiftUI

public struct Home: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var selectedTab: Tab = .users
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            AnimationTabbarView(selectedTab: $selectedTab)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Github Users")
        .toolbar {
            if appState.isLoggedIn {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        coordinator.push(.settings)
                    }) {
                        Image(systemName: "gearshape") // Custom icon
                            .font(.title)
                            .foregroundColor(.black)
                            .imageScale(.small)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .users:
            GithubUsersView()
        case .books:
            ListBooksView(viewModel: ListBooksViewModel())
        }
    }
}
