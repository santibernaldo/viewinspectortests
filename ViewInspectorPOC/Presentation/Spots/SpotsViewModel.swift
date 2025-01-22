//
//  SpotsViewModel.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 22/1/25.
//

import SwiftUI

@Observable
public class SpotsViewModel: ObservableObject {
    
    private let loader: SpotsLoader
    
    public var isLoading: Bool = false
    var spots: [SpotItem] = []
    
    public init(loader: SpotsLoader) {
        self.loader = loader
    }
    
    func loadSpots() async {
        do {
            isLoading = true
            let result = try await loader.load()
            switch result {
            case .success(let spots):
                assert(Thread.isMainThread, "UI updates must be performed on the main thread.")
                self.spots = spots
                self.isLoading = false
            case .failure:
                isLoading = false
            }
        } catch {
            isLoading = false
        }
    }
}
