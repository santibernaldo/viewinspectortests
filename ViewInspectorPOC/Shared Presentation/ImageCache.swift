//
//  ImageCache.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//


import UIKit

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
    func remove(for url: URL)
    func removeExpiredImages()
}

// InMemory Cache using NSCache for the images
class TemporaryImageCache: ImageCache {
    private class CacheImage {
        let image: UIImage
        let expirationDate: Date
        
        init(image: UIImage, expirationDate: Date) {
            self.image = image
            self.expirationDate = expirationDate
        }
    }
    
    private let cache = NSCache<NSURL, CacheImage>()
    private var keys = Set<NSURL>() // Track keys manually
    private let calendar = Calendar(identifier: .gregorian)
    
    // Subscript for accessing cached images
    subscript(_ key: URL) -> UIImage? {
        get {
            let nsURL = key as NSURL
            if let cacheImage = cache.object(forKey: nsURL) {
                if Date() < cacheImage.expirationDate {
                    return cacheImage.image
                } else {
                    // Item has expired, remove it
                    cache.removeObject(forKey: nsURL)
                    keys.remove(nsURL)
                }
            }
            return nil
        }
        set {
            let nsURL = key as NSURL
            if let image = newValue {
                let expirationDate = calendar.date(byAdding: .day, value: 1, to: Date())!
                let entry = CacheImage(image: image, expirationDate: expirationDate)
                cache.setObject(entry, forKey: nsURL)
                keys.insert(nsURL) // Track the key
            } else {
                cache.removeObject(forKey: nsURL)
                keys.remove(nsURL) // Remove the key
            }
        }
    }
    
    // Remove a specific URL from the cache
    func remove(for url: URL) {
        let nsURL = url as NSURL
        cache.removeObject(forKey: nsURL)
        keys.remove(nsURL)
    }
    
    // Remove all expired images from the cache
    func removeExpiredImages() {
        for key in keys {
            if let cacheImage = cache.object(forKey: key), Date() >= cacheImage.expirationDate {
                cache.removeObject(forKey: key)
                keys.remove(key) // Remove the expired key
            }
        }
    }
}
