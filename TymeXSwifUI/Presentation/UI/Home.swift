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
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        TabView {
            ListUsersView(viewModel: viewModel)
                .tabItem {
                    Label("List", systemImage: "list.dash")
                }
            
            GridUsersView(viewModel: viewModel)
                .tabItem {
                    Label("Grid", systemImage: "rectangle.grid.2x2")
                }
        }
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
}
