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

extension APIRepository {
    //This guarantees order (A → B → C). If one fails, it still continues.
    func uploadMultipleSequential<T: Decodable>(
      endPoint: APIRequest,
      images: [Data],
      fileNamePrefix: String = "photo",
      mimeType: String = "image/jpeg",
      formField: String = "file",
      httpCodes: HTTPCodes = .success
    ) async -> [UploadResult<T>] {
        var results: [UploadResult<T>] = []
        
        for (index, data) in images.enumerated() {
            do {
                let response: T = try await upload(
                    endPoint: endPoint,
                    fileData: data,
                    fileName: "\(fileNamePrefix)_\(UUID().uuidString).jpg",
                    mimeType: mimeType,
                formField: formField,
                httpCodes: httpCodes)
                results.append(UploadResult(index: index, response: response, error: nil))
            } catch {
                results.append(UploadResult(index: index, response: nil, error: error))
            }
        }
        return results
    }
    
    func uploadMultipleConcurrently<T: Decodable>(
        endPoint: APIRequest,
        images: [Data],
        fileNamePrefix: String = "photo",
        mimeType: String = "image/jpeg",
        formField: String = "file",
        httpCodes: HTTPCodes = .success
    ) async -> [UploadResult<T>] {
        await withTaskGroup(of: UploadResult<T>.self) { group in
            for (index, data) in images.enumerated() {
                group.addTask {
                    do {
                        let response: T = try await self.upload(
                            endPoint: endPoint,
                            fileData: data,
                            fileName: "\(fileNamePrefix)_\(UUID().uuidString).jpg",
                            mimeType: mimeType,
                            formField: formField,
                            httpCodes: httpCodes
                        )
                        return UploadResult(index: index, response: response, error: nil)
                    } catch {
                        return UploadResult(index: index, response: nil, error: error)
                    }
                }
            }
            
            var results = Array<UploadResult<T>?>(repeating: nil, count: images.count)
            for await result in group {
                results[result.index] = result
            }
            return results.compactMap { $0 }
        }
    }
    /// Upload 1 file/image via multipart/form
    func upload<T: Decodable>(
        endPoint: APIRequest,
        fileData: Data,
        fileName: String,
        mimeType: String,
        formField: String = "file", // Ex: "file" hoặc "image"
        httpCodes: HTTPCodes = .success
    ) async throws -> T {
        
        var request = try endPoint.urlRequest()
        request.httpMethod = "POST"
        
        // Boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Body
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(formField)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        logRequest(request)
        
        // Call API
        let (data, response) = try await session.data(for: request)
        logResponse(response, data: data)
        
        guard let code = (response as? HTTPURLResponse)?.statusCode,
              httpCodes.contains(code) else {
            throw APIError.unexpectedResponse
        }
        
        // 6. Decode response
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch let err as DecodingError {
            throw APIError.decodingError(err)
        } catch {
            throw APIError.unexpectedResponse
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

