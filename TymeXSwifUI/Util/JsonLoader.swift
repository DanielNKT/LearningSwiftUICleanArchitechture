//
//  JsonLoader.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 10/3/25.
//
import Foundation

public struct JSONLoader {
    enum JsonLoaderError: Error {
        case fileNotFound(String)
        case dataLoadError(String, Error)
        case decodingError(String, Error)
    }
    
    static func loadJSON(from fileName: String, in bundle: Bundle = .main) throws -> Data {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw JsonLoaderError.fileNotFound("\(fileName).json not found in bundle.")
        }
        do {
            return try Data(contentsOf: url)
        } catch let error {
            throw JsonLoaderError.dataLoadError("Failed to load data from \(fileName).json", error)
        }
    }
    
    static func decodeJSON<T: Decodable>(_ type: T, from fileName: String, in bundle: Bundle = .main) throws -> T {
        let data = try loadJSON(from: fileName, in: bundle)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            throw JsonLoaderError.decodingError("Failed to decode \(fileName).json", error)
        }
    }
}
