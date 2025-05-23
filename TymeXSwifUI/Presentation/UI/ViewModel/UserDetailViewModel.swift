//
//  UserDetailViewModel.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import Foundation
import Combine

class UserDetailViewModel: ObservableObject {
    @Published var hasLoaded = false
    @Published var user: User? = nil
    @Published var userName: String
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    private let userUseCases: UserUseCases
    private var cancellables = Set<AnyCancellable>()
    
    init(userUseCases: UserUseCases, userName: String) {
        self.userUseCases = userUseCases
        self.userName = userName
    }
    
    func fetchUsers() {
        self.isLoading = true
        userUseCases.fetchDetailUser.execute(name: self.userName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { (user: User) in
                self.isLoading = false
                self.user = user
            })
            .store(in: &cancellables)
        
    }
    
    @MainActor
    private func updateUserList(users: User){
        self.user = user
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
