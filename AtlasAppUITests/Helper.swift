//
//  Helper.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 3/14/18.
//

import Foundation
import XCTest

func waitForElementToAppear(_ element: XCUIElement) -> Bool {
    let predicate = NSPredicate(format: "exists == true")
    let expectation = XCTNSPredicateExpectation(predicate: predicate,
                                                object: element)
    
    let result = XCTWaiter().wait(for: [expectation], timeout: 5)
    return result == .completed
}

//func assertTerminalContains(_ text: String) {
//    let terminal = app.textViews["terminal"]
//    let terminalText = terminal.value as? String ?? ""
//    XCTAssertNotNil(terminalText.range(of: text), "The terminal does not contain the text: \(text)")
//}
//
//func assertTerminalDoesNotContain(_ text: String) {
//    let terminal = app.textViews["terminal"]
//    let terminalText = terminal.value as? String ?? ""
//    XCTAssertNil(terminalText.range(of: text), "The terminal contains the text: \(text)")
//}
//
//func waitForTerminalToContain(_ text: String) {
//    let terminal = app.textViews["terminal"]
//
//    let contains = NSPredicate(format: "value contains[c] %@", text)
//
//    let subsitutedContains = contains.withSubstitutionVariables(["text": text])
//
//    expectation(for: subsitutedContains, evaluatedWith: terminal, handler: nil)
//    waitForExpectations(timeout: 30, handler: nil)
//}

