//
//  CacheImageViewTest.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 19/3/25.
//

import XCTest
import Combine

@testable import TymeXSwifUI

class CacheImageViewTest: XCTestCase {
    var imageLoader: ImageLoader!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        imageLoader = ImageLoader()
        cancellables = []
    }
    
    override func tearDown() {
        imageLoader = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testImageCaching() {
        let testURL = URL(string: "https://example.com/test.png")!
        let testImage = UIImage(systemName: "photo")!
        let cacheEntry = ImageCache.CacheEntry(image: testImage, timestamp: Date())
        ImageCache.shared.setObject(cacheEntry, forKey: NSString(string: testURL.absoluteString))
        
        let expectation = XCTestExpectation(description: "Load cached image")
        
        imageLoader.$image.sink { image in
            if let image = image {
                XCTAssertEqual(image, testImage)
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        imageLoader.load(from: testURL)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testImageLoadingFromNetwork() {
        let testURL = URL(string: "https://example.com/test.png")!
        
        let expectation = XCTestExpectation(description: "Load image from network")
        
        imageLoader.$image.sink { image in
            if image != nil {
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        imageLoader.load(from: testURL)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCancelImageLoading() {
        let testURL = URL(string: "https://example.com/test.png")!
        imageLoader.load(from: testURL)
        imageLoader.cancel()
        XCTAssertTrue(imageLoader.isCancelled, "Image loading should be cancelled and subscriptions removed.")
    }
    
    func testCacheExpiration() {
        let testURL = URL(string: "https://example.com/test.png")!
        let testImage = UIImage(systemName: "photo")!
        let expiredTimestamp = Date().addingTimeInterval(-61) // 61 seconds ago
        let validTimestamp = Date().addingTimeInterval(-30) // 30 seconds ago
        
        let expiredCacheEntry = ImageCache.CacheEntry(image: testImage, timestamp: expiredTimestamp)
        let validCacheEntry = ImageCache.CacheEntry(image: testImage, timestamp: validTimestamp)
        
        // Set expired entry
        ImageCache.shared.setObject(expiredCacheEntry, forKey: NSString(string: testURL.absoluteString))
        imageLoader.load(from: testURL, cacheDuration: 60)
        print(imageLoader.image ?? "Nil")
        XCTAssertNil(imageLoader.image, "Expired cache should not be used.")

        // Set valid entry
        ImageCache.shared.setObject(validCacheEntry, forKey: NSString(string: testURL.absoluteString))
        imageLoader.load(from: testURL, cacheDuration: 60)
        XCTAssertEqual(imageLoader.image, testImage, "Valid cache should be used.")
    }
}
