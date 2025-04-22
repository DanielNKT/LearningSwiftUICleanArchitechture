//
//  UserServiceTests.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 20/3/25.
//
import XCTest
import Combine
@testable import TymeXSwifUI

final class UserServiceTests: XCTestCase {
    
    private var userUseCases: UserUseCases!
    private var mockUserRepository: MockUserRepository!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        userUseCases = UserUseCases(userRepository: mockUserRepository)
    }
    
    override func tearDown() {
        userUseCases = nil
        mockUserRepository = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Async Tests
    
//    func testFetchListUser_Success() async throws {
//        // Given
//        let data = try JSONLoader.loadJSON(from: "Users") // returns Data
//        let expectedUsers = try JSONDecoder().decode(Users.self, from: data)
//        
//        mockUserRepository.listUsersResult = .success(expectedUsers)
//        
//        // When
//        let users = try await userService.fetchListUser(params: UserListRequest())
//        
//        // Then
//        XCTAssertEqual(users.count, expectedUsers.count)
//    }
//    
//    func testFetchListUser_Failure() async {
//        // Given
//        mockUserRepository.listUsersResult = .failure(APIError.unexpectedResponse)
//        
//        // When / Then
//        do {
//            _ = try await userService.fetchListUser(params: UserListRequest())
//            XCTFail("Expected failure but got success")
//        } catch {
//            XCTAssertTrue(error is APIError)
//        }
//    }
    
//    func testFetchDetailUser_Success() async throws {
//        // Given
//        let data = try JSONLoader.loadJSON(from: "UserDetail")
//        let expectedUser = try JSONDecoder().decode(User.self, from: data)
//        mockUserRepository.getUserResult = .success(expectedUser)
//        
//        // When
//        let user = try await userService.fetchDetailUser(name: "Test Login Name")
//        
//        // Then
//        XCTAssertEqual(user.name, expectedUser.name)
//    }
//    
//    func testFetchDetailUser_Failure() async {
//        // Given
//        mockUserRepository.getUserResult = .failure(APIError.unexpectedResponse)
//        
//        // When / Then
//        do {
//            _ = try await userService.fetchDetailUser(name: "Test Login Name")
//            XCTFail("Expected failure but got success")
//        } catch {
//            XCTAssertTrue(error is APIError)
//        }
//    }
    
    // MARK: - Combine Tests
    
    func testFetchListUserReturnAnyPublisher_Success() {
        // Given
        do {
            let data = try JSONLoader.loadJSON(from: "Users") // returns Data
            let expectedUsers = try JSONDecoder().decode(Users.self, from: data)
            
            mockUserRepository.listUsersPublisherResult = Just(expectedUsers)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
            
            let expectation = XCTestExpectation(description: "Publisher should return expected users")
            
            // When
            userUseCases.fetchUser.execute(params: UserListRequest())
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got failure: \(error)")
                    }
                }, receiveValue: { users in
                    // Then
                    XCTAssertEqual(users.count, expectedUsers.count)
                    expectation.fulfill()
                })
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: 1.0)
        } catch {
            XCTFail("Failed to load mock data")
        }
        
    }
    
    func testFetchListUserReturnAnyPublisher_Failure() {
        // Given
        mockUserRepository.listUsersPublisherResult = Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Publisher should return failure")
        
        // When
        userUseCases.fetchUser.execute(params: UserListRequest())
            .sink(receiveCompletion: { completion in
                // Then
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, .unexpectedResponse)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchDetailUserReturnAnyPublisher_Success() {
        do {
            // Given
            let userData = try JSONLoader.loadJSON(from: "UserDetail")
            let expectedUser = try JSONDecoder().decode(User.self, from: userData)
            mockUserRepository.getUserPublisherResult = Just(expectedUser)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
            
            let expectation = XCTestExpectation(description: "Publisher should return expected user")
            
            // When
            userUseCases.fetchDetailUser.execute(name: "Test Login Name")
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got failure: \(error)")
                    }
                }, receiveValue: { user in
                    // Then
                    XCTAssertEqual(user.name, expectedUser.name)
                    expectation.fulfill()
                })
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: 1.0)
        } catch {
            XCTFail("Failed to load mock data")
        }
        
    }
    
    func testFetchDetailUserReturnAnyPublisher_Failure() {
        // Given
        mockUserRepository.getUserPublisherResult = Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Publisher should return failure")
        
        // When
        userUseCases.fetchDetailUser.execute(name: "Test Login Name")
            .sink(receiveCompletion: { completion in
                // Then
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, .unexpectedResponse)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1.0)
    }
}
