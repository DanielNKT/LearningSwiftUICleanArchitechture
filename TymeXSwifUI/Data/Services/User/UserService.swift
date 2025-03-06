//
//  UserService.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

protocol UserServiceProtocol {
    func fetchListUser(params: UserListRequest) async throws -> [User]
    func fetchDetailUser(name: String) async throws -> User
    func fetchListUserReturnAnyPublisher(params: UserListRequest) -> AnyPublisher<[User], APIError>
    func fetchDetailUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError>
}

struct UserService: UserServiceProtocol {
    
    let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func fetchListUser(params: UserListRequest) async throws -> [User] {
        return try await userRepository.listUsers(params)
    }
    
    func fetchDetailUser(name: String) async throws -> User {
        return try await userRepository.getUser(name: name)
    }
    
    func fetchListUserReturnAnyPublisher(params: UserListRequest) -> AnyPublisher<[User], APIError> {
        return userRepository.listUsersReturnAnyPublisher(params)
    }
    
    func fetchDetailUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError> {
        return userRepository.getUserReturnAnyPublisher(name: name)
    }
}
