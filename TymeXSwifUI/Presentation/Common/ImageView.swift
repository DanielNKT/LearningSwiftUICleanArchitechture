//
//  ImageView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import SwiftUI
import Combine

class ImageCache {
    static let shared = NSCache<NSString, CacheEntry>()
    
    class CacheEntry {
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
    private var cancellable: AnyCancellable?
    private let cacheDuration: TimeInterval = 60 // 1 minute
    
    func load(from url: URL) {
        let cacheKey = NSString(string: url.absoluteString)
        
        if let cachedEntry = ImageCache.shared.object(forKey: cacheKey), Date().timeIntervalSince(cachedEntry.timestamp) < cacheDuration {
            image = cachedEntry.image
            return
            
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data)}
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadedImage in
                if let image = downloadedImage {
                    let entry = ImageCache.CacheEntry(image: image, timestamp: Date())
                    ImageCache.shared.setObject(entry, forKey: cacheKey)
                }
                self?.image = downloadedImage
            }
        
    }
    func cancel() {
        cancellable?.cancel()
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
