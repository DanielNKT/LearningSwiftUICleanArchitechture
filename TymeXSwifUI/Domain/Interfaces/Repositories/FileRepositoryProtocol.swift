//
//  FileRepositoryProtocol.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 1/10/25.
//

import Foundation
import Combine

protocol FileRepositoryProtocol {
    func uploadImageReturnPublisher(
        imageData: Data,
        fileName: String,
        mimeType: String
    ) -> AnyPublisher<UploadResponse, APIError>
    
    func uploadImage(
        imageData: Data,
        fileName: String,
        mimeType: String
    ) async throws -> UploadResponse
    
    func uploadMultipleImages(
        images: [Data],
        fileNamePrefix: String,
        mimeType: String,
        formField: String
    ) async -> [UploadResult<UploadResponse>]
}

