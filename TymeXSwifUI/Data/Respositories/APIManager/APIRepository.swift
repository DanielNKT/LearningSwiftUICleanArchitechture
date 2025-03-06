//
//  APIClient.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation
import Combine

protocol APIRequest {
    var path: String { get }
    var parameters: [String : Any]? { get }
    var method: String { get }
    var headers: [String: String]? { get }
    func body() throws -> Data?
}

extension APIRequest {
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: AppEnviroment.baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let params = parameters {
            request.addParameters(params, method: method)
        }
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        if let bodyData = try body() {
            request.httpBody = bodyData
        }
        return request
    }
}

class APIRepository {
    private let session: URLSession
    
    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }
    
    init(session: URLSession = configuredURLSession()) {
        self.session = session
    }
    
    func request<T: Decodable>(
        endPoint: APIRequest,
        httpCodes: HTTPCodes = .success
    ) async throws -> T {
        let request = try endPoint.urlRequest()
        let (data, response) = try await session.data(for: request)
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw APIError.unexpectedResponse
        }
        guard httpCodes.contains(code) else {
            throw APIError.serverError(code)
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.unexpectedResponse
        }
    }
    func request<T: Decodable>(
        endPoint: APIRequest,
        httpCodes: HTTPCodes = .success
    ) -> AnyPublisher<T, APIError> {
        do {
            let request = try endPoint.urlRequest()
            
            return session.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.unexpectedResponse
                    }
                    guard httpCodes.contains(httpResponse.statusCode) else {
                        throw APIError.serverError(httpResponse.statusCode)
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    return error is DecodingError ? APIError.unexpectedResponse : APIError.networkError(error)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.invalidRequest(error))
                .eraseToAnyPublisher()
        }
    }
}

