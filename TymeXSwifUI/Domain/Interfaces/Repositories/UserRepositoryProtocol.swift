//
//  UserRepositoryProtocol.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 22/4/25.
//

import Combine

protocol UserRepositoryProtocol {
    func listUsers(_ params: Parameters) async throws -> Users
    func getUser(name: String) async throws -> User
    func listUsersReturnAnyPublisher(_ params: Parameters) -> AnyPublisher<Users, APIError>
    func getUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError>
}
