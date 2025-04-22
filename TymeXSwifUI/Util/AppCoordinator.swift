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
    private let userUseCases: UserUseCases
    
    init() {
        self.userRepository = UserRepository(apiRepository: apiRepository)
        self.userUseCases = UserUseCases(userRepository: userRepository)
    }
    
    enum DestinationType: Hashable {
        case home
        case detail(String)
        case login
        case settings
        case listUser
        case gridUser
        case testSegmentControl
    }
    
    func push(_ destination: DestinationType) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func resetToLogin() {
        path = NavigationPath() // Clears the navigation stack
    }
    
    @ViewBuilder func view(for destination: DestinationType) -> some View {
        switch destination {
        case .home:
            let viewModel = HomeViewModel(userUseCases: self.userUseCases)
            Home(viewModel: viewModel)
        case .detail(let name):
            let viewModel = UserDetailViewModel(userUseCases: userUseCases, userName: name)
            UserDetail(viewModel: viewModel)
        case .login:
            let viewModel = LoginViewModel()
            LoginView(viewModel: viewModel)
        case .settings:
            SettingsView()
        case .listUser:
            let viewModel = HomeViewModel(userUseCases: self.userUseCases)
            ListUsersView(viewModel: viewModel)
        case .gridUser:
            let viewModel = HomeViewModel(userUseCases: self.userUseCases)
            GridUsersView(viewModel: viewModel)
        case .testSegmentControl:
            TestSegmentedView()
        }
    }
}
