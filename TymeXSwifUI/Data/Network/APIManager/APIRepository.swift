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
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    func body() throws -> Data?
}

extension APIRequest {
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: AppEnviroment.baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
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
    
    private static let sharedURLSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }()
    
    init(session: URLSession = APIRepository.sharedURLSession) {
        self.session = session
    }
    
    func request<T: Decodable>(
        endPoint: APIRequest,
        httpCodes: HTTPCodes = .success
    ) async throws -> T {
        let request = try endPoint.urlRequest()
        logRequest(request)
        let (data, response) = try await session.data(for: request)
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw APIError.unexpectedResponse
        }
        // ✅ Log Response Details
        logResponse(response, data: data)
        
        guard httpCodes.contains(code) else {
            throw APIError.serverError(code)
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch let decodingError as DecodingError {
            logError("Decoding Error: \(decodingError)")
            throw APIError.decodingError(decodingError)
        } catch {
            logError("Unexpected Response Error")
            throw APIError.unexpectedResponse
        }
    }
    func request<T: Decodable>(
        endPoint: APIRequest,
        httpCodes: HTTPCodes = .success
    ) -> AnyPublisher<T, APIError> {
        do {
            let request = try endPoint.urlRequest()
            logRequest(request)
            
            return session.dataTaskPublisher(for: request)
                .tryMap { [weak self] data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.unexpectedResponse
                    }
                    // ✅ Log Response Details
                    self?.logResponse(response, data: data)
                    
                    guard httpCodes.contains(httpResponse.statusCode) else {
                        throw APIError.serverError(httpResponse.statusCode)
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { [weak self] error in
                    if let decodingError = error as? DecodingError {
                        self?.logError("Decoding Error: \(decodingError)")
                        return APIError.decodingError(decodingError)
                    }
                    self?.logError("Network Error: \(error.localizedDescription)")
                    return APIError.networkError(error)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.invalidRequest(error))
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Logging Functions
extension APIRepository {
    private func logRequest(_ request: URLRequest) {
        print("""
        📡 API Request:
        URL: \(request.url?.absoluteString ?? "Unknown URL")
        Method: \(request.httpMethod ?? "Unknown Method")
        Headers: \(request.allHTTPHeaderFields ?? [:])
        Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "No Body")
        """)
    }
    
    private func logResponse(_ response: URLResponse, data: Data?) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Body"
        print("""
        ✅ API Response:
        URL: \(httpResponse.url?.absoluteString ?? "Unknown URL")
        Status Code: \(httpResponse.statusCode)
        Headers: \(httpResponse.allHeaderFields)
        Body: \(responseBody)
        """)
    }
    
    private func logError(_ message: String) {
        print("❌ API Error: \(message)")
    }
}

