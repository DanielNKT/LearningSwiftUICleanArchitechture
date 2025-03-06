//
//  UserService.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

protocol UserServiceProtocol {
    func fetchListUser() async throws -> [User]
    func fetchDetailUser(name: String) async throws -> User
    func fetchListUserReturnAnyPublisher() -> AnyPublisher<[User], APIError>
    func fetchDetailUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError>
}

struct UserService: UserServiceProtocol {
    
    let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func fetchListUser() async throws -> [User] {
        return try await userRepository.listUsers()
    }
    
    func fetchDetailUser(name: String) async throws -> User {
        return try await userRepository.getUser(name: name)
    }
    
    func fetchListUserReturnAnyPublisher() -> AnyPublisher<[User], APIError> {
        return userRepository.listUsersReturnAnyPublisher()
    }
    
    func fetchDetailUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError> {
        return userRepository.getUserReturnAnyPublisher(name: name)
    }
}
