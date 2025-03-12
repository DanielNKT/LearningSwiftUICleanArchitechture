//
//  ContentView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 3/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var coordinator = AppCoordinator()
    @StateObject var appState = AppState()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            if appState.isLoggedIn {
                coordinator.view(for: .home)
                    .navigationDestination(for: AppCoordinator.DestinationType.self) { destination in
                        coordinator.view(for: destination)
                    }
            } else {
                coordinator.view(for: .login)
                    .navigationDestination(for: AppCoordinator.DestinationType.self) { destination in
                        coordinator.view(for: destination)
                    }
            }
            
        }
        .environmentObject(coordinator)
        .environmentObject(appState)
    }
}
