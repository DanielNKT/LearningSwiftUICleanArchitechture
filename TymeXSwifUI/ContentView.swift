//
//  ContentView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 3/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var appState = AppState()
    
    @State private var cachedView: AnyView = AnyView(EmptyView())
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            cachedView
                .navigationDestination(for: AppCoordinator.DestinationType.self) { destination in
                    coordinator.view(for: destination)
                }
        }
        .environmentObject(coordinator)
        .environmentObject(appState)
        .onAppear {
            updateMainView()
        }
        .onChange(of: appState.isLoggedIn) { oldValue, newValue in
            updateMainView()
        }
    }
    
    private func updateMainView() {
        cachedView = AnyView(
            mainView()
        )
    }
    
    @ViewBuilder
    private func mainView() -> some View {
        if appState.isLoggedIn {
            coordinator.view(for: .home)
        } else {
            coordinator.view(for: .login)
        }
    }
}
