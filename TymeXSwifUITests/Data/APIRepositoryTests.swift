//
//  AppCoordinatoorTest.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 8/3/25.
//
import XCTest
import Combine
@testable import TymeXSwifUI 

class APIRepositoryTests: XCTestCase {
    private var apiRepository: APIRepository!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        apiRepository = APIRepository(session: session)
    }
    
    override func tearDown() {
        apiRepository = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testRequest_SuccessfulResponse() async throws {
        // Mock API response data
        let mockData = try JSONLoader.loadJSON(from: "UserDetail")
        URLProtocolMock.requestHandler = { _ in
            return (HTTPURLResponse(url: URL(string: "https://api.test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!, mockData)
        }
        
        let mockEndpoint = MockAPIRequest()
        let user: User = try await apiRepository.request(endPoint: mockEndpoint)
        
        XCTAssertEqual(user.id, 102)
        XCTAssertEqual(user.login, "BrianTheCoder")
        XCTAssertEqual(user.name, "Brian Smith")
    }
    
    func testRequest_FailureResponse() async {
        URLProtocolMock.requestHandler = { _ in
            return (HTTPURLResponse(url: URL(string: "https://api.test.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)!, Data())
        }
        
        let mockEndpoint = MockAPIRequest()
        
        do {
            let _: User = try await apiRepository.request(endPoint: mockEndpoint)
            XCTFail("Expected failure but got success")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.serverError(500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRequest_Publisher_SuccessfulResponse() {
        let expectation = XCTestExpectation(description: "Publisher request should succeed")
        let mockData = try! JSONLoader.loadJSON(from: "UserDetail")
        
        URLProtocolMock.requestHandler = { _ in
            return (HTTPURLResponse(url: URL(string: "https://api.test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!, mockData)
        }
        
        let mockEndpoint = MockAPIRequest()
        apiRepository.request(endPoint: mockEndpoint)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            }, receiveValue: { (user: User) in
                XCTAssertEqual(user.id, 1)
                XCTAssertEqual(user.login, "testUser")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
