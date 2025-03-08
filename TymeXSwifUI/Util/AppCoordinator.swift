//
//  AppCoordinator.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import SwiftUI

// MARK: - Coordinator Protocol
// MARK: - App Coordinator
class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    // ✅ Shared dependencies (created once)
    private let apiRepository = APIRepository()
    private let userRepository: UserRepository
    private let userService: UserService

    init() {
        self.userRepository = UserRepository(apiRepository: apiRepository)
        self.userService = UserService(userRepository: userRepository)
    }

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
            let viewModel = HomeViewModel(service: userService)
            Home(viewModel: viewModel)
        case .detail(let name):
            let viewModel = UserDetailViewModel(service: userService, userName: name)
            UserDetail(viewModel: viewModel)
        }
    }
}
