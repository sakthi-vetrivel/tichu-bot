@testable import Tichu
//
//  PlayableTest.swift
//  TichuTests
//
//  Created by Sakthi Vetrivel on 12/28/23.
//

import XCTest

class PlayableTest: XCTestCase {
        // Test to make sure special cards are played correctly as singles
    func testDragonAndPhoenixAsSingles() {
        let 
        ]
        let generatedStairs = cards.generateStairs()

        XCTAssertEqual(generatedStairs.count, 1, "Should generate one set of stairs with Phoenix")
        XCTAssertEqual(generatedStairs.first?.count, 4, "The stairs should include 4 cards (including Phoenix)")
    }

}