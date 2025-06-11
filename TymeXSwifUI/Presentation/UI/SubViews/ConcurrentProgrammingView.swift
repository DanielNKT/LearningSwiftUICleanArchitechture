//
//  ConcurrentProgrammingView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 21/5/25.
//

import SwiftUI
import Combine
import Foundation

struct ConcurrentProgrammingView: View {
    
    
    
    var body: some View {
        List {
            multipleRequestSection
        }
        .onAppear {
            test()
        }
    }
    
    func test() {
        let shouldFail = false
        
        let cancellables = Just(())
            .setFailureType(to: MyError.self)
            .flatMap { _ -> AnyPublisher<String, MyError> in
                if shouldFail {
                    return Fail(error: MyError.somethingWentWrong)
                        .eraseToAnyPublisher()
                } else {
                    return Just("Success!")
                        .setFailureType(to: MyError.self)
                        .eraseToAnyPublisher()
                }
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Complete without error")
                    case .failure(let error):
                        print("Failed with error \(error)")
                    }
                }, receiveValue: { value in
                        print("Received value: \(value)")
                }
            )
    }
    
    private var multipleRequestSection: some View {
        Section(header: Text("Multiple Request").font(.headline)) {
            Button("Test multiple concurrent tasks") {
                Task {
                    await fetchAll()
                }
            }
        }
        .listRowSeparator(.hidden)
    }
}

extension ConcurrentProgrammingView {
    func fetchAll() async {
        async let result1 = fetchData1()
        async let result2 = fetchData2()
        async let result3 = fetchData3()
        
        do {
            let (data1, data2, data3) = try await (result1, result2, result3)
            print("All done: \(data1), \(data2), \(data3)")
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func fetchData1() async throws -> String {
        // simulate a network call
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "Data1"
    }
    
    func fetchData2() async throws -> String {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return "Data2"
    }
    
    func fetchData3() async throws -> String {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        return "Data3"
    }
}

enum MyError: Error {
    case somethingWentWrong
}
