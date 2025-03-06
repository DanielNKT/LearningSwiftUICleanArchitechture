//
//  HTTPMethod.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/3/25.
//
import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

enum APIError {
    case invalidURL
    case serverError(HTTPCode)
    case unexpectedResponse
    case noData
    case networkError(Error)
    case invalidRequest(Error)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError(let httpCode): return "Server error: \(httpCode)"
        case .unexpectedResponse: return "Unexpected response from the server"
        case .noData: return "No data was received from the server."
        case .networkError(let error): return error.localizedDescription
        case .invalidRequest(let error): return error.localizedDescription
        }
    }
}

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
}
