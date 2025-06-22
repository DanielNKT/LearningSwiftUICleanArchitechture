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
    
    private var usersView: AnyView {
        return AnyView(coordinator.view(for: .githubUsers))
    }

    private var booksView: AnyView {
        return AnyView(coordinator.view(for: .listBook))
    }
    
    public var body: some View {
        TabView {
            coordinator.view(for: .githubUsers)
                .tabItem {
                    Label("Users", systemImage: "list.dash")
                }
            
            coordinator.view(for: .listBook)
                .tabItem {
                    Label(LocalizableKey.books, systemImage: "book.fill")
                }
        }
//        VStack(spacing: 0) {
//            tabContent
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//            AnimationTabbarView(selectedTab: $selectedTab)
//                .padding(.bottom, 10)
//        }
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
            coordinator.view(for: .githubUsers)
        case .books:
            coordinator.view(for: .listBook)
        }
    }
}
