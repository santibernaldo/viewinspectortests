//
//  SpotsView.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 22/1/25.
//

import SwiftUI

public struct SpotsView: View {
    @ObservedObject private var viewModel: SpotsViewModel
    
    public init(viewModel: SpotsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            headerView
        }
        .task {
            await loadSpots()
        }
        .refreshable {
            await loadSpots()
        }
        
    }
    
    @ViewBuilder
    private var headerView: some View {
        ProgressView("Is loading...")
            .opacity(viewModel.isLoading ? 1 : 0)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(viewModel.spots) { spot in
                    Text("\(spot.title)")
                }
            }
            .padding(.horizontal)
        }
        
    }
    
    private func loadSpots() async {
        await viewModel.loadSpots()
    }
}
