//
//  SpotsViewTests.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

import XCTest
import ViewInspectorPOC
import ViewInspector

final class SpotsViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        FirebaseTestConfigurator.configureForTests()
    }
    
    func test_init_doesNotLoadSpots() {
        let (_, loader, _) = makeSUT()
        
        XCTAssertEqual(loader.spotsCallCount, 0)
    }
    
    @MainActor
    func test_onAppear_loadsSpots() async throws {
        let (sut, loader, _) = makeSUT()
        
        // Render the view
        // simulate onAppear
        let inspectedView = try sut.inspect()
        try await inspectedView.find(ViewType.VStack.self).callTask()
        
        XCTAssertEqual(loader.spotsCallCount, 1, "Expected spots to load onAppear")
    }
    
    @MainActor
    func test_pullToRefresh_loadsSpots() async throws {
        let (sut, loader, _) = makeSUT()
        
        // Render the view
        // simulate onAppear
        let inspectedView = try sut.inspect()
        try await inspectedView.find(ViewType.VStack.self).callTask()
        
        try await inspectedView.find(ViewType.VStack.self).callRefreshable()
        XCTAssertEqual(loader.spotsCallCount, 2, "Expected spots to load onAppear")
        
        try await inspectedView.find(ViewType.VStack.self).callRefreshable()
        XCTAssertEqual(loader.spotsCallCount, 3, "Expected spots to load onAppear")
    }
    
    @MainActor
    func test_isLoadingTrue_showsLoadingIndicator() async throws {
        let (sut, loader, viewModel) = makeSUT()
        
        // Render the view
        let inspectedView = try sut.inspect()
        
        // Stub the loader to return immediately
        loader.completeLoadingSuccessfully(spots: [])
        
        // Before loading starts, ProgressView should not be visible
        XCTAssertEqual(try inspectedView.find(ViewType.ProgressView.self).opacity(), 0)
        
        viewModel.isLoading = true
        
        // Verify the loading state
        XCTAssertEqual(try inspectedView.find(ViewType.ProgressView.self).opacity(), 1)
        
        // Simulate the end of loading
        viewModel.isLoading = false
        
        // Verify the ProgressView disappears after loading
        XCTAssertEqual(try inspectedView.find(ViewType.ProgressView.self).opacity(), 0)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() async throws {
        let (sut, loader, _) = makeSUT()
        
        let inspectedView = try await MainActor.run {
            try sut.inspect()
        }
        
        let exp = expectation(description: "Wait for background queue")
        
        Task { @MainActor in
            do {
                try await inspectedView.find(ViewType.VStack.self).callTask()
            } catch {
                XCTFail("Error executing callTask: \(error)")
            }
        }
        
        DispatchQueue.global().async {
            loader.completeLoadingSuccessfully(spots: [])
            exp.fulfill()
        }
        
        await fulfillment(of: [exp], timeout: 1.0)
    }
    
    private func makeSUT(documentID: String = "",
                         file: StaticString = #filePath,
                         line: UInt = #line
    ) -> (sut: SpotsView, loader: SpotsLoaderSpy, viewModel: SpotsViewModel) {
        let loader = SpotsLoaderSpy()
        let viewModel = SpotsViewModel(loader: loader)
        let sut = SpotsView(viewModel: viewModel)
        return (sut, loader, viewModel)
    }
    
    class SpotsLoaderSpy: SpotsLoader {
        private var resultGetSpots: Result<[SpotItem], Swift.Error> = .failure(Error.anyError as Error)
        var spotsCallCount = 0
        
        enum Error: Swift.Error {
            case anyError
        }
        
        func completeLoadingSuccessfully(spots: [SpotItem]) {
            resultGetSpots = .success(spots)
        }
        
        func load() async throws -> SpotsLoader.Result {
            spotsCallCount += 1
            return resultGetSpots
        }
    }
}

private final class MainQueueDispatchDecorator: SpotsLoader {
    private let decoratee: SpotsLoader
    
    init(decoratee: SpotsLoader) {
        self.decoratee = decoratee
    }
    
    @MainActor
    func load() async throws -> SpotsLoader.Result {
        let result = try await decoratee.load()
        return result
    }
}
