//
//  URLSessionExtention.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 7/3/25.
//
import Foundation

extension URLRequest {
    mutating func addParameters(_ parameters: [String: Any]?, method: String) {
        guard let parameters else { return }
        if method == HTTPMethod.GET.rawValue {
                guard var urlComponents = URLComponents(url: self.url!, resolvingAgainstBaseURL: false) else { return }
                urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                self.url = urlComponents.url
            } else {
                self.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
                self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
}

class Parameters {
    func toDictionary() -> [String: Any]? {
        var dict: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        
        for (key, value) in mirror.children {
            if let key = key {
                dict[key] = value
            }
        }
        return dict
    }
}
