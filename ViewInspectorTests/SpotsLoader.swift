//
//  SpotsLoader.swift
//  ViewInspectorTests
//
//  Created by Santiago Ochoa Bernaldo de Quiros on 16/1/25.
//

public protocol SpotsLoader {
    typealias Result = Swift.Result<[SpotItem], Error>
    
    func load() async throws -> Result
}
