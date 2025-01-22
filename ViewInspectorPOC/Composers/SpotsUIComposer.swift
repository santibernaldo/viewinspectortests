//
//  SpotCommentsUIComposer.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 21/1/25.
//

import SwiftUI
import FirebaseFirestore

public struct SpotsUIComposer {
    
    @MainActor public static func compose(loader: SpotsLoader) -> (view: SpotsView, viewModel: SpotsViewModel) {        
        let viewModel = SpotsViewModel(loader: loader)
        
        let spotCommentsView = SpotsView(viewModel: viewModel)
        return (spotCommentsView, viewModel)
    }
    
}


