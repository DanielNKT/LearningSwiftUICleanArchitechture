//
//  WebSocketManager.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 1/10/25.
//

import Foundation
import UIKit
import Combine

/* WebSocket: connect → subscribe channel → listen → send message (HTTP) → receive event (socket)
 - Connect WebSocket when view did load
 - Subscribe channel (ex: conversationId)
 - Listen to receive Event
 - Send message via HTTP Api
 - Server broadcast event -> Client will receive via Socket
 */
final class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    
    //Connection Handler
    private var isConnected = false
    private var reconnectAttempts = 0
    private var maxReconnectAttempts: Int = 5
    private var pingTimer: Timer?
    let messageSubject = PassthroughSubject<ChatMessage, Never>() //For purpos update UI in View
    
    //Endpoint
    private let endpoint: String
    private var cancellables = Set<AnyCancellable>()
    
    init(endpoint: String) {
        self.endpoint = endpoint
        self.session = URLSession(configuration: .default)
    }
    
    func connect() {
        guard !isConnected else { return }
        guard let url = URL(string: endpoint) else { return }
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
        reconnectAttempts = 0
        print("🔌 WebSocket connected")
        
        listenEvent()
        startPinging()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("❌ Disconnected")
    }
    
    func sendMessage(_ text: String) {
        guard isConnected else {
            print("⚠️ Socket not connected")
            self.handleDisconnect()
            return
        }
        guard !text.isEmpty else { return }
        webSocketTask?.send(.string(text)) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("⚠️ Send error: \(error)")
                self.handleDisconnect()
            } else {
                print("📤 Sent: \(text)")
            }
        }
    }
    
    private func listenEvent() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("⚠️ Receive error: \(error)")
                self.handleDisconnect()
                
            case .success(let message):
                self.handleMessage(message)
                self.listenEvent()
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            print("📩 Received text: \(text)")
            if let data = text.data(using: .utf8) {
                if let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: data) {
                    messageSubject.send(chatMessage)
                }
            }
        case .data(let data):
            print("📩 Received binary (\(data.count) bytes)")
        @unknown default:
            print("⚠️ Unknown message")
        }
    }
    
    private func startPinging() {
        DispatchQueue.main.async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.webSocketTask?.sendPing { error in
                    if let error = error {
                        print("⚠️ Ping failed: \(error)")
                        self.handleDisconnect()
                    } else {
                        print("📡 Ping sent")
                    }
                }
            }
        }
    }
    
    private func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func handleDisconnect() {
        guard isConnected else { return }
        isConnected = false
        stopPinging()
        
        reconnectAttempts += 1
        if reconnectAttempts <= maxReconnectAttempts {
            let delay = pow(2.0, Double(reconnectAttempts)) // exponential backoff
            print("🔄 Attempting reconnect in \(delay)s (try \(reconnectAttempts))")
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.connect()
            }
        } else {
            print("⛔ Max reconnect attempts reached, giving up")
        }
    }
    
    func sendImage(_ image: UIImage, fileUseCases: FileUseCases) {
        // 1. Convert UIImage -> Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to data")
            return
        }
        
        Task {
            do {
                // 3. Upload image lên server
                let response = try await fileUseCases.execute(
                    fileData: imageData,
                    fileName: "photo_\(UUID().uuidString).jpg",
                    mimeType: "image/jpeg"
                )
                
                print("✅ Image uploaded: \(response.url)")
                
                // 4. Sau khi upload thành công -> gửi message qua WebSocket
                let messageDict: [String: Any] = [
                    "type": "image",
                    "url": response.url,
                    "timestamp": Int(Date().timeIntervalSince1970)
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: messageDict),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.sendMessage(jsonString)
                }
                
            } catch {
                print("❌ Upload image failed: \(error)")
            }
        }
    }
    
    func sendImagePublisher(_ image: UIImage, fileUseCases: FileUseCases) {
        // 1. Convert UIImage -> Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to data")
            return
        }
        
        fileUseCases.executePublisher(
            fileData: imageData,
            fileName: "photo_\(UUID().uuidString).jpg",
            mimeType: "image/jpeg"
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .failure(let error):
                print("❌ Failed to upload image: \(error)")
            case .finished:
                print("✅ Image uploaded successfully")
            }
        } receiveValue: { [weak self] response in
            // 4. Sau khi upload thành công -> gửi message qua WebSocket
            guard let self = self else { return }
            let messageDict: [String: Any] = [
                "type": "image",
                "url": response.url,
                "timestamp": Int(Date().timeIntervalSince1970)
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: messageDict),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.sendMessage(jsonString)
            }
        }
        .store(in: &cancellables)
    }
    
    func sendImagesAsGallery(_ images: [UIImage], fileUseCase: FileUseCases) {
        Task {
            var urls: [String] = []
            
            for image in images {
                guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
                do {
                    let response = try await fileUseCase.execute(
                        fileData: imageData,
                        fileName: "photo_\(UUID().uuidString).jpg",
                        mimeType: "image/jpeg"
                    )
                    urls.append(response.url)
                } catch {
                    print("❌ Failed to upload one image: \(error)")
                }
            }
            
            guard !urls.isEmpty else { return }
            
            let messageDict: [String: Any] = [
                "type": "gallery",
                "urls": urls,
                "timestamp": Int(Date().timeIntervalSince1970)
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: messageDict),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.sendMessage(jsonString)
            }
        }
    }
    
    func sendImagesAsGalleryButParralel(_ images: [UIImage], fileUseCase: FileUseCases) {
        Task {
            let imageDataArray = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
            guard !imageDataArray.isEmpty else {
                print("❌ No valid images to upload")
                return
            }
            let results = await fileUseCase.uploadMultipleParallel(
                images: imageDataArray,
                mimeType: "image/jpeg", 
                fileNamePrefix: "gallery"
            )
            
            let uploadedURLs = results.compactMap { result -> String? in
                if let url = result.response?.url {
                    print("✅ Uploaded image \(result.index): \(url)")
                    return url
                } else {
                    print("❌ Failed to upload image \(result.index): \(result.error?.localizedDescription ?? "unknown error")")
                    return nil
                }
            }
            
            guard !uploadedURLs.isEmpty else {
                print("❌ All uploads failed. Skip sending message.")
                return
            }
            
            // 5️⃣ Build payload gửi qua socket
            let messageDict: [String: Any] = [
                "type": "gallery",
                "urls": uploadedURLs,
                "timestamp": Int(Date().timeIntervalSince1970)
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: messageDict),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                // 6️⃣ Gửi tin nhắn qua WebSocket
                self.sendMessage(jsonString)
                print("📤 Sent gallery message: \(jsonString)")
            }
        }
    }
}
