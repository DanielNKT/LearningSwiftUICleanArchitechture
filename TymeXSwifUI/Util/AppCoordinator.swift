//
//  AppCoordinator.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import SwiftUI

// MARK: - Coordinator Protocol
protocol Coordinator: ObservableObject {
    associatedtype Destination: View
    
    @ViewBuilder func view(for destination: AppCoordinator.DestinationType) -> Destination
}

// MARK: - App Coordinator
class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    enum DestinationType: Hashable {
        case home
        case detail(String)
    }
    
    func push(_ destination: DestinationType) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    @ViewBuilder func view(for destination: DestinationType) -> some View {
        switch destination {
        case .home:
            let apiRepository = APIRepository()
            let userRepository = UserRepository(apiRepository: apiRepository)
            let service = UserService(userRepository: userRepository)
            let viewModel = HomeViewModel(service: service)
            Home(viewModel: viewModel)
        case .detail(let name):
            let apiRepository = APIRepository()
            let userRepository = UserRepository(apiRepository: apiRepository)
            let service = UserService(userRepository: userRepository)
            let viewModel = UserDetailViewModel(service: service, userName: name)
            UserDetail(viewModel: viewModel)
        }
    }
}
