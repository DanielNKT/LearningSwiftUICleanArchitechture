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

    private let apiRepository = APIRepository()
    private let userRepository: UserRepository
    private let userUseCases: UserUseCases

    // ✅ Cached view models
    private var homeViewModel: HomeViewModel!
    private var listViewModel: HomeViewModel!
    private var gridViewModel: HomeViewModel!
    private var listBooksViewModel: ListBooksViewModel!
    private var githubUsersViewModel: GithubUsersViewModel!

    init() {
        self.userRepository = UserRepository(apiRepository: apiRepository)
        self.userUseCases = UserUseCases(userRepository: userRepository)
        self.homeViewModel = HomeViewModel(userUseCases: userUseCases)
        self.listViewModel = HomeViewModel(userUseCases: userUseCases)
        self.gridViewModel = HomeViewModel(userUseCases: userUseCases)
        self.listBooksViewModel = ListBooksViewModel()
        self.githubUsersViewModel = GithubUsersViewModel()
    }

    enum DestinationType: Hashable {
        case home
        case detail(String)
        case login
        case settings
        case listUser
        case gridUser
        case githubUsers
        case concurrentProgramming
        case listBook
        case profile
    }

    func push(_ destination: DestinationType) {
        path.append(destination)
    }

    func pop() {
        path.removeLast()
    }

    func resetToLogin() {
        path = NavigationPath()
    }

    @ViewBuilder
    func view(for destination: DestinationType) -> some View {
        switch destination {
        case .home:
            Home(viewModel: homeViewModel)
        case .detail(let name):
            // Detail may not be reused – instantiate as needed
            let detailViewModel = UserDetailViewModel(userUseCases: userUseCases, userName: name)
            UserDetailView(viewModel: detailViewModel)
        case .login:
            LoginView(viewModel: LoginViewModel())
        case .settings:
            SettingsView(viewModel: SettingsViewModel())
        case .listUser:
            ListUsersView(viewModel: listViewModel)
        case .gridUser:
            GridUsersView(viewModel: gridViewModel)
        case .githubUsers:
            GithubUsersView(viewModel: githubUsersViewModel)
        case .concurrentProgramming:
            ConcurrentProgrammingView()
        case .listBook:
            ListBooksView(viewModel: listBooksViewModel)
        case .profile:
            ProfileView()
        }
    }
}

