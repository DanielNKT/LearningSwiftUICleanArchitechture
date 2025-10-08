//
//  FileUseCases.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 1/10/25.
//

import Foundation
import Combine

final class FileUseCases {
    private let repository: FileRepositoryProtocol
    
    init(repository: FileRepositoryProtocol) {
        self.repository = repository
    }
    
    /// Combine style (AnyPublisher)
    func executePublisher(
        fileData: Data,
        fileName: String,
        mimeType: String
    ) -> AnyPublisher<UploadResponse, APIError> {
        return repository.uploadImageReturnPublisher(
            imageData: fileData,
            fileName: fileName,
            mimeType: mimeType
        )
    }
    
    /// async/await style
    func execute(
        fileData: Data,
        fileName: String,
        mimeType: String
    ) async throws -> UploadResponse {
        return try await repository.uploadImage(
            imageData: fileData,
            fileName: fileName,
            mimeType: mimeType
        )
    }
    
    func uploadMultipleParallel(
                images: [Data],
                mimeType: String = "image/jpeg",
                fileNamePrefix: String = "photo",
                formField: String = "image"
    ) async -> [UploadResult<UploadResponse>] {
        return await repository.uploadMultipleImages(images: images, fileNamePrefix: fileNamePrefix, mimeType: mimeType, formField: formField)
    }
}
