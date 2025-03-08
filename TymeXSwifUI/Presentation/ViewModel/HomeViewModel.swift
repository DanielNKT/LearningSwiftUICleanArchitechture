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
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let service: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(service: UserServiceProtocol) {
        self.service = service
    }
    
    func fetchUsers(perPage: Int = 20, page: Int = 0) {
        self.isLoading = true
        let params = UserListRequest()
        params.per_page = perPage
        params.since = page
        
        service.fetchListUserReturnAnyPublisher(params: params)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { (users: [User]) in
                self.isLoading = false
                self.users.append(contentsOf: users)
            })
            .store(in: &cancellables)
        
    }
    
    @MainActor
    private func updateUserList(users: [User]){
        self.users = users
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
