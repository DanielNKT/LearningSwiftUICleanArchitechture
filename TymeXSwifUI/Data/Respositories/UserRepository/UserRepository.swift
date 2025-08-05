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
        return apiRepository.request(endPoint: UserUrl.listUser(params))
    }
    
    func getUserReturnAnyPublisher(name: String) -> AnyPublisher<User, APIError> {
        if AppEnviroment.isAlpha {
            return returnMockUserDetailData(name: name)
        }
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
    var parameters: Parameters? {
        switch self {
        case .listUser(let request):
            return request
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
    
    func returnMockUserDetailData(name: String) -> AnyPublisher<User, APIError> {
        Result {
            let data = try JSONLoader.loadJSON(from: "UserDetail") // returns Data
            return try JSONDecoder().decode(User.self, from: data)
        }
        .publisher
        .mapError { _ in APIError.unexpectedResponse }
        .eraseToAnyPublisher()
    }
}
