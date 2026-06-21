//
//  AppEnviroment.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import Foundation

struct AppEnviroment {
    static let baseURL: String = value(for: "BaseURL")
    static let isAlpha: Bool = value(for: "IsAlpha") == "YES"

    private static func value(for key: String) -> String {
        guard let value = Bundle.main.infoDictionary?[key] as? String, !value.isEmpty else {
            fatalError("❌ Missing required Info.plist key: '\(key)'. Add it to Info.plist and all xcconfig files.")
        }
        return value
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
