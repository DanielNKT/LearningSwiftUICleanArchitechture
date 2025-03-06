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
    
    func fetchUsers() {
        //        do {
        //            let users = try await service.fetchListUser()
        //            await updateUserList(users: users)
        //            await updateLoadingState(isLoading: false)
        //        } catch {
        //            await updateLoadingState(isLoading: false)
        //            await updateErrorMessage(message: error.localizedDescription)
        //        }
        self.isLoading = true
        service.fetchListUserReturnAnyPublisher()
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
                self.users = users
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
