//
//  UserUseCases.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

final class FetchListUserUseCase {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(params: UserListRequest) -> AnyPublisher<Users, APIError> {
        return repository.listUsersReturnAnyPublisher(params)
    }
}

final class FetchDetailUserUseCase {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(name: String) -> AnyPublisher<User, APIError> {
        return repository.getUserReturnAnyPublisher(name: name)
    }
}

final class UserUseCases {
    
    let fetchUser: FetchListUserUseCase
    let fetchDetailUser: FetchDetailUserUseCase
        
    init(userRepository: UserRepositoryProtocol) {
        self.fetchUser = FetchListUserUseCase(repository: userRepository)
        self.fetchDetailUser = FetchDetailUserUseCase(repository: userRepository)
    }
}
