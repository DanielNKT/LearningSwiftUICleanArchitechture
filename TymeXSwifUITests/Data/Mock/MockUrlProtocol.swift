//
//  MockUrlProtocol.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 8/3/25.
//
import XCTest
import Combine
@testable import TymeXSwifUI

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
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
    var parameters: [String : Any]? = nil
    
    var method: String = HTTPMethod.GET.rawValue
    
    var headers: [String : String]? = nil
    
    func body() throws -> Data? {
        return nil
    }
    
    var path: String { "/mock" }
}

struct MockResponse: Codable {
    let id: Int
    let name: String
}
