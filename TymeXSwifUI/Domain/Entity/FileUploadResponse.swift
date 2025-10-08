//
//  FileUploadResponse.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 1/10/25.
//

struct UploadResponse: Decodable {
    let url: String
    let status: String
}

struct UploadResult<T: Decodable> {
    let index: Int
    let response: T?
    let error: Error?
    
    var isSucess: Bool {
        response != nil
    }
}
