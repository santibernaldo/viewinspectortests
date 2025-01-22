//
//  AsyncImageImageLoader.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import SwiftUI

struct AsyncImageImageLoader<Placeholder: View, Content: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let isLoading: Bool
    private let content: (UIImage) -> Content
    
    init(
        url: URL,
        isLoading: Bool = false,
        @ViewBuilder placeholder: () -> Placeholder,
        cache: ImageCache,
        @ViewBuilder content: @escaping (UIImage) -> Content
    ) {
        self.placeholder = placeholder()
        self.content = content
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: cache)) // Pass cache explicitly
        self.isLoading = isLoading
    }
    
    
    var body: some View {
        contentView
            .onAppear(perform: loader.load)
    }
    
    @MainActor
    private var contentView: some View {
        Group {
            if let image = loader.image {
                content(image)
            } else {
                placeholder
            }
        }
    }
}
