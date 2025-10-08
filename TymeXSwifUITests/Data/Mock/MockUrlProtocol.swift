//
//  MockUrlProtocol.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 8/3/25.
//
import Foundation
import Combine
@testable import TymeXSwifUI

class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

struct MockAPIRequest: APIRequest {
    var path: String { "/mock/user" }
    var parameters: Parameters? { nil }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    func body() throws -> Data? { nil }
}
