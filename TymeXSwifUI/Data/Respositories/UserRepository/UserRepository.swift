//
//  UserService.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

class UserRepository: UserRepositoryProtocol {
    
    private let apiRepository: APIRepository
    
    init(apiRepository: APIRepository) {
        self.apiRepository = apiRepository
    }
    
    func listUsersReturnAnyPublisher(_ params: Parameters) -> AnyPublisher<[User], APIError> {
        if AppEnviroment.isAlpha {
            return returnMockUsersData()
        }
        return apiRepository.request(endPoint: UserEndpoint.listUser(params))
    }
    
    func getUserReturnAnyPublisher(_ params: Parameters) -> AnyPublisher<User, APIError> {
        if AppEnviroment.isAlpha {
            return returnMockUserDetailData()
        }
        return apiRepository.request(endPoint: UserEndpoint.getUser(params))
    }
    
    func listUsers(_ params: Parameters) async throws -> Users {
        return try await apiRepository.request(endPoint: UserEndpoint.listUser(params))
    }
    
    func getUser(_ params: Parameters) async throws -> User {
        return try await apiRepository.request(endPoint: UserEndpoint.getUser(params))
    }
}

extension UserRepository {
    enum UserEndpoint {
        case listUser(Parameters?)
        case getUser(Parameters?)
    }
}

extension UserRepository.UserEndpoint: APIRequest {
    var parameters: Parameters? {
        switch self {
        case .listUser(let request):
            return request
        case .getUser(let request):
            return request
        }
    }
    
    var path: String {
        switch self {
        case .listUser:
            return "/users"
        case .getUser(let name):
            return "/users"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .listUser, .getUser:
            return HTTPMethod.GET
        }
    }
    
    var headers: [String : String]? {
        //return ["Accept": "application/json", "Authorization" : "Your Template Token"]
        return nil
    }
    
    func body() throws -> Data? {
        return nil
    }
}

extension UserRepository {
    func returnMockUsersData() -> AnyPublisher<[User], APIError> {
        Result {
            let data = try JSONLoader.loadJSON(from: "Users") // returns Data
            return try JSONDecoder().decode(Users.self, from: data)
        }
        .publisher
        .mapError { _ in APIError.unexpectedResponse }
        .eraseToAnyPublisher()
    }
    
    func returnMockUserDetailData() -> AnyPublisher<User, APIError> {
        Result {
            let data = try JSONLoader.loadJSON(from: "UserDetail") // returns Data
            return try JSONDecoder().decode(User.self, from: data)
        }
        .publisher
        .mapError { _ in APIError.unexpectedResponse }
        .eraseToAnyPublisher()
    }
}
