//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedAppTests
//
//  Created by Arifin Firdaus on 13/12/20.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(for instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potental memory leaks.", file: file, line: line)
        }
    }
    
}
