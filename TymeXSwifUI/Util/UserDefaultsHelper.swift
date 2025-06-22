//
//  UserDefaultHelper.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 21/6/25.
//

import Foundation

final class UserDefaultsHelper {
    private static let defaults = UserDefaults.standard
    
    static func get<T>(key: String) -> T? {
        return defaults.object(forKey: key) as? T
    }
    
    static func set<T>(_ value: T, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    static func getObject<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
    
    static func setObject<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            defaults.set(encoded, forKey: key)
        }
    }
}

extension UserDefaultsHelper {
    static var language: String? {
        get { get(key: UserDefaultsKeys.language.rawValue) }
        set { set(newValue, forKey: UserDefaultsKeys.language.rawValue)}
    }
    
    static var firstLaunch: Bool {
        get { get(key: UserDefaultsKeys.isFirstLaunch.rawValue) ?? false }
        set { set(newValue, forKey: UserDefaultsKeys.isFirstLaunch.rawValue)}
    }
}

enum UserDefaultsKeys: String {
    case isFirstLaunch
    case language
}
