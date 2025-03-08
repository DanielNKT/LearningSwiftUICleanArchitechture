//
//  AppCoordinatoorTest.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 8/3/25.
//
import XCTest
import Combine
@testable import TymeXSwifUI 

final class APIRepositoryTests: XCTestCase {
    private var apiRepository: APIRepository!
    private var mockSession: URLSession!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        
        // ✅ Use a mock URLSession with testable responses
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        
        apiRepository = APIRepository(session: mockSession)
    }

    override func tearDown() {
        apiRepository = nil
        mockSession = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - ✅ Test: Successful API Call (Async/Await)
    func testRequest_SuccessfulResponse() async throws {
        // Arrange
        let mockData = """
        {
            "id": 1,
            "name": "John Doe"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, mockData)
        }
        
        let endpoint = MockAPIRequest()
        
        // Act
        let result: MockResponse = try await apiRepository.request(endPoint: endpoint)
        
        // Assert
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "John Doe")
    }

    // MARK: - ❌ Test: API Call with Server Error (Async/Await)
    func testRequest_ServerError() async {
        // Arrange
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let endpoint = MockAPIRequest()
        
        // Act & Assert
        do {
            let _: MockResponse = try await apiRepository.request(endPoint: endpoint)
            XCTFail("Expected APIError.serverError but succeeded")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.serverError(500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - ✅ Test: Successful API Call (Combine)
    func testRequestPublisher_SuccessfulResponse() {
        // Arrange
        let mockData = """
        {
            "id": 2,
            "name": "Jane Doe"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, mockData)
        }
        
        let expectation = XCTestExpectation(description: "Successful API response")
        let endpoint = MockAPIRequest()
        
        // Act
        apiRepository.request(endPoint: endpoint)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected failure: \(error)")
                }
            }, receiveValue: { (result: MockResponse) in
                // Assert
                XCTAssertEqual(result.id, 2)
                XCTAssertEqual(result.name, "Jane Doe")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - ❌ Test: API Call with Network Error (Combine)
    func testRequestPublisher_NetworkError() {
        // Arrange
        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }
        
        let expectation = XCTestExpectation(description: "API should fail due to network error")
        let endpoint = MockAPIRequest()
        
        // Act
        apiRepository.request(endPoint: endpoint)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, APIError.networkError(URLError(.notConnectedToInternet)))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected network error")
                }
            }, receiveValue: { (_: MockResponse) in
                XCTFail("Unexpected success")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
