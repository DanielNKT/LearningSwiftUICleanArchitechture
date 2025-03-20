//
//  MockUserRepository.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 20/3/25.
//
import Combine
@testable import TymeXSwifUI

// MARK: - MockUserRepository

class MockUserRepository: UserRepositoryProtocol {

    var listUsersResult: Result<Users, Error>?
    var getUserResult: Result<User, Error>?
    var listUsersPublisherResult: AnyPublisher<[User], APIError>?
    var getUserPublisherResult: AnyPublisher<User, APIError>?

    func listUsers(_ params: Parameters) async throws -> Users {
        if let result = listUsersResult {
            return try result.get()
        }
        throw APIError.unexpectedResponse
    }

    func getUser(name: String) async throws -> User {
        if let result = getUserResult {
            return try result.get()
        }
        throw APIError.unexpectedResponse
    }

    func listUsersReturnAnyPublisher(_ params: Parameters) -> AnyPublisher<[User], APIError> {
        return listUsersPublisherResult ?? Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
    }

    func getUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError> {
        return getUserPublisherResult ?? Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
    }
}
