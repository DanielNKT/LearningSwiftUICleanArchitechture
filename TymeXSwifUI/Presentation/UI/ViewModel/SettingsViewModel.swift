//
//  SettingsViewModel.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 31/3/25.
//
import Combine
import Foundation

struct MyResult {
    let id: Int
    let data: String?
    let error: Error?
}

class SettingsViewModel: ObservableObject {
    
    @Published var currentLanguage: LanguageSupport = LanguageManager.shared.currentLanguage == LanguageSupport.English.rawValue ? .English : .Vietnamese

    func fetchData(id: Int) async throws -> String {
        if id % 2 == 0 {
            return "Data for \(id)"
        } else {
            throw NSError(domain: "FetchError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch \(id)"])
        }
    }
    
    func performMultiRequests() async {
        let ids: [Int] = [1, 2, 3, 4, 5]
        var results: [MyResult] = []
        await withTaskGroup(of: MyResult?.self) { [weak self] group in
            guard let self else { return }
            for id in ids {
                group.addTask {
                    do {
                        let data = try await self.fetchData(id: id)
                        return MyResult(id: id, data: data, error: nil)
                    } catch {
                        return MyResult(id: id, data: nil, error: error)
                    }
                }
            }
            
            for await result in group {
                if let result = result {
                    results.append(result)
                }
            }
        }
        
        for result in results {
            if let data = result.data {
                print("✅ Success for id \(result.id): \(data)")
            } else if let error = result.error {
                print("❌ Failure for id \(result.id): \(error.localizedDescription)")
            }
        }
    }
}
