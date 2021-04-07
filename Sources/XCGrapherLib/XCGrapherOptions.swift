//
//  File.swift
//  
//
//  Created by Max Chuquimia on 2/4/21.
//

import Foundation

public protocol XCGrapherOptions {
    var project: String { get }
    var target: String { get }
    var podlock: String { get }
    var output: String { get }
    var apple: Bool { get }
    var spm: Bool { get }
    var pods: Bool { get }
    var force: Bool { get }
    var plugin: String { get }
}
