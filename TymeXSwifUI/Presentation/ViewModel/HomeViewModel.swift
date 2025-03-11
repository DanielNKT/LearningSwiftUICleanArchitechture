//
//  HomeViewModel.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var hasLoaded = false
    @Published var users: Users = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    /// Pagination properties
    @Published var activeUserId: Int?
    @Published var lastUserId: Int?
    
    private var since: Int = 0
    
    private let service: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(service: UserServiceProtocol) {
        self.service = service
    }
    
    func fetchUsers(perPage: Int = 20, page: Int = 0) {
        self.isLoading = true
        let params = UserListRequest()
        params.per_page = perPage
        params.since = self.since
        
        
        service.fetchListUserReturnAnyPublisher(params: params)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] (users: Users) in
                guard let self else { return }
                self.isLoading = false
                // Filter out duplicate users based on ID
                let uniqueUsers = users.filter { newUser in
                    !self.users.contains(where: { $0.id == newUser.id })
                }
                
                self.users.append(contentsOf: uniqueUsers)
                self.lastUserId = users.last?.id
                if self.since == 0 {
                    self.since = perPage + 1
                } else {
                    self.since += perPage
                }
                print("Users count: \(self.users.count) ")
            })
            .store(in: &cancellables)
        
    }
    
    @MainActor
    private func updateUserList(users: Users){
        self.users.append(contentsOf: users)
    }
    
    @MainActor
    private func updateLoadingState(isLoading: Bool){
        self.isLoading = isLoading
    }
    
    @MainActor
    private func updateErrorMessage(message: String?){
        self.errorMessage = message
    }
}
