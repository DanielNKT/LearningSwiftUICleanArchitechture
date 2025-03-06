//
//  UserService.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

protocol UserRepositoryProtocol {
    func listUsers() async throws -> [User]
    func getUser(name: String) async throws -> User
    func listUsersReturnAnyPublisher() -> AnyPublisher<[User], APIError>
    func getUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError>
}

class UserRepository: UserRepositoryProtocol {
    
    func listUsersReturnAnyPublisher() -> AnyPublisher<[User], APIError> {
        return APIClient.shared.requestReturnAnyPublisher(endPoint: UserUrl.listUser)
    }
    
    func getUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError> {
        return APIClient.shared.requestReturnAnyPublisher(endPoint: UserUrl.getUser(name: name))
    }
    
    func listUsers() async throws -> [User] {
        return try await APIClient.shared.request(endPoint: UserUrl.listUser)
    }
    
    func getUser(name: String) async throws -> User {
        return try await APIClient.shared.request(endPoint: UserUrl.getUser(name: name))
    }
}

extension UserRepository {
    enum UserUrl {
        case listUser
        case getUser(name: String)
    }
}

extension UserRepository.UserUrl: APIRequest {
    var path: String {
        switch self {
            case .listUser:
            return "/users"
        case .getUser(let name):
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return "/users/\(encodedName ?? name)"
        }
    }
    
    var method: String {
        switch self {
        case .listUser, .getUser:
            return HTTPMethod.GET.rawValue
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
    
    func body() throws -> Data? {
        return nil
    }
    
    
}
