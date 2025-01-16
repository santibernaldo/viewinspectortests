//
//  SpotsViewTests.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

import ViewInspectorTests
import Foundation
import XCTest
import ViewInspector
import SwiftUI

struct SpotView: View {
    private let loader: SpotsLoader
    
    public init(loader: SpotsLoader) {
        self.loader = loader
    }
    
    var body: some View {
        VStack {
            Text("")
                
        }
        .onAppear {
            Task {
               try? await loader.load()
            }
        }
        
    }
}

final class SpotsViewTests: XCTestCase {
    
    func test_init_doesNotLoadSpots() {
        let loader = LoaderSpy()
        
        let _ = SpotView(loader: loader)
        
        XCTAssertEqual(loader.spotsCallCount, 0)
    }
    
    func test_onAppear_loadsSpots() throws {
        let loader = LoaderSpy()
        let sut = SpotView(loader: loader)

        // Render the view
        // simulate onAppear
        let inspectedView = try sut.inspect()
        try inspectedView.find(ViewType.VStack.self).callOnAppear()

        XCTAssertEqual(loader.spotsCallCount, 1, "Expected spots to load onAppear")
    }
    
    
    class LoaderSpy: SpotsLoader {
        private var resultUploadDocument: Result<[SpotItem], Swift.Error> = .failure(Error.anyError as Error)
        
        enum Error: Swift.Error {
            case anyError
        }
        
        var spotsCallCount = 0
        
        func load() async throws -> SpotsLoader.Result {
            spotsCallCount += 1
            
            return resultUploadDocument
        }
    }

}
