//
//  XCTestCase+MemoryLeaksTrackingHelper.swift
//  ViewInspectorPOC
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 22/1/25.
//


import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #filePath,
                                     line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
    
}
