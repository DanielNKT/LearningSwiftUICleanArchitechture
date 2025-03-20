//
//  ImageView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import SwiftUI
import Combine

class ImageCache {
    static let shared = NSCache<NSString, AnyObject>()
    
    class CacheEntry: NSObject {
        let image: UIImage
        let timestamp: Date
        
        init(image: UIImage, timestamp: Date) {
            self.image = image
            self.timestamp = timestamp
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellables = Set<AnyCancellable>()
    var isCancelled: Bool {
        cancellables.isEmpty
    }
    func load(from url: URL, cacheDuration: TimeInterval = 60) {
        let cacheKey = NSString(string: url.absoluteString)
        
        if let cachedEntry = ImageCache.shared.object(forKey: cacheKey) as? ImageCache.CacheEntry, Date().timeIntervalSince(cachedEntry.timestamp) < cacheDuration {
            image = cachedEntry.image
            return
            
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Image loading failed: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] downloadedImage in
                guard let self = self else { return }
                let entry = ImageCache.CacheEntry(image: downloadedImage, timestamp: Date())
                ImageCache.shared.setObject(entry, forKey: cacheKey)
                self.image = downloadedImage
            })
            .store(in: &cancellables)
        
    }
    func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

// MARK: - Cached Async Image View
struct CachedAsyncImage: View {
    @StateObject private var loader = ImageLoader()
    let url: URL
    let placeholder: Image
    
    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        loader.load(from: url)
                    }
                    .onDisappear {
                        loader.cancel()
                    }
            }
        }
    }
}
