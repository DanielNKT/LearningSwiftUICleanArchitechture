//
//  FileRepository.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 1/10/25.
//
import Foundation
import Combine

class FileRepository: FileRepositoryProtocol {
    
    private let apiRepository: APIRepository
    
    init(apiRepository: APIRepository) {
        self.apiRepository = apiRepository
    }
    
    // MARK: - AnyPublisher (Combine)
    func uploadImageReturnPublisher(
        imageData: Data,
        fileName: String,
        mimeType: String
    ) -> AnyPublisher<UploadResponse, APIError> {
        Future { promise in
            Task {
                do {
                    let response: UploadResponse = try await self.apiRepository.upload(
                        endPoint: FileEndpoint.uploadImage,
                        fileData: imageData,
                        fileName: fileName,
                        mimeType: mimeType
                    )
                    promise(.success(response))
                } catch let error as APIError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unexpectedResponse))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - async/await
    func uploadImage(
        imageData: Data,
        fileName: String,
        mimeType: String
    ) async throws -> UploadResponse {
        return try await apiRepository.upload(
            endPoint: FileEndpoint.uploadImage,
            fileData: imageData,
            fileName: fileName,
            mimeType: mimeType
        )
    }
    
    func uploadMultipleImages(
        images: [Data],
        fileNamePrefix: String,
        mimeType: String,
        formField: String) async -> [UploadResult<UploadResponse>] {
            return await apiRepository.uploadMultipleConcurrently(
                endPoint: FileEndpoint.uploadImage,
                images: images,
                fileNamePrefix: fileNamePrefix,
                mimeType: mimeType,
                formField: formField
            )
        }
}

extension FileRepository {
    enum FileEndpoint {
        case uploadImage
        case uploadFile
    }
}

extension FileRepository.FileEndpoint: APIRequest {
    var parameters: Parameters? {
        return nil
    }
    
    var path: String {
        switch self {
        case .uploadImage:
            return "/upload/image"
        case .uploadFile:
            return "/upload/file"
        }
    }
    
    var method: HTTPMethod {
        return .POST
    }
    
    var headers: [String : String]? {
        // nếu cần token thì thêm vào đây
        return ["Accept": "application/json"]
    }
    
    func body() throws -> Data? {
        // multipart đã build riêng trong APIRepository.upload()
        return nil
    }
}
