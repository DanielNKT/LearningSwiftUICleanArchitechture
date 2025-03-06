//
//  ContentView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 3/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(for: .home)
                .navigationDestination(for: AppCoordinator.DestinationType.self) { destination in
                    coordinator.view(for: destination)
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    let apiRepository = APIRepository()
    let userRepository = UserRepository(apiRepository: apiRepository)
    let service = UserService(userRepository: userRepository)
    let viewModel = HomeViewModel(service: service)
    Home(viewModel: viewModel)
}
