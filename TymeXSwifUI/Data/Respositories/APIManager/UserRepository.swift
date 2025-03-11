//
//  UserService.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

protocol UserRepositoryProtocol {
    func listUsers(_ params: Parameters) async throws -> Users
    func getUser(name: String) async throws -> User
    func listUsersReturnAnyPublisher(_ params: Parameters) -> AnyPublisher<Users, APIError>
    func getUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError>
}

class UserRepository: UserRepositoryProtocol {
    
    private let apiRepository: APIRepository
    
    init(apiRepository: APIRepository) {
        self.apiRepository = apiRepository
    }
    
    func listUsersReturnAnyPublisher(_ params: Parameters) -> AnyPublisher<[User], APIError> {
        return apiRepository.request(endPoint: UserUrl.listUser(params))
    }
    
    func getUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError> {
        return apiRepository.request(endPoint: UserUrl.getUser(name: name))
    }
    
    func listUsers(_ params: Parameters) async throws -> Users {
        return try await apiRepository.request(endPoint: UserUrl.listUser(params))
    }
    
    func getUser(name: String) async throws -> User {
        return try await apiRepository.request(endPoint: UserUrl.getUser(name: name))
    }
}

extension UserRepository {
    enum UserUrl {
        case listUser(Parameters?)
        case getUser(name: String)
    }
}

extension UserRepository.UserUrl: APIRequest {
    var parameters: [String : Any]? {
        switch self {
        case .listUser(let request):
            return request?.toDictionary()
        case .getUser:
            return nil
        }
    }
    
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
        return ["Accept": "application/json", "Authorization" : "token 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"]
    }
    
    func body() throws -> Data? {
        return nil
    }
    
    
}
