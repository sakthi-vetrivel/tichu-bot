@testable import Tichu
//
//  GenerateHands.swift
//  TichuTests
//
//  Created by Sakthi Vetrivel on 12/20/23.
//

import XCTest

class GenerateHands: XCTestCase {
    
    func testGeneratePairsTripsFours() {
        let cards: Stack = [
            Card(rank: .three, suit: .hearts),
            Card(rank: .three, suit: .spades),
            Card(rank: .three, suit: .diamonds),
            Card(rank: .four, suit: .diamonds),
            Card(rank: .four, suit: .clubs),
            Card(rank: .five, suit: .hearts)
        ]

        let expectedPairsCount = 4
        let expectedTripsCount = 1
        let expectedFourOfAKindsCount = 0

        let generatedHands = cards.generatePairsTripsFours()
        let pairs = generatedHands.filter { $0.count == 2 }
        let trips = generatedHands.filter { $0.count == 3 }
        let fourOfAKinds = generatedHands.filter { $0.count == 4 }

        XCTAssertEqual(pairs.count, expectedPairsCount)
        XCTAssertEqual(trips.count, expectedTripsCount)
        XCTAssertEqual(fourOfAKinds.count, expectedFourOfAKindsCount)
        
        let validHands = cards.generateAllPossibleHands()
        XCTAssertEqual(validHands.count, 13)
    }

    func testGenerateStraightsWithPhoenix() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .three, suit: .spades),
            Card(rank: .five, suit: .clubs),
            Card(rank: .six, suit: .hearts),
            Card(rank: .phoenix, suit: .diamonds)
        ]

        let expectedStraightsCount = 1
        let generatedStraights = cards.generateStraights()
        
        XCTAssertEqual(generatedStraights.count, expectedStraightsCount)
    }
    
    func testGenerateStraightsWithDuplicates() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .three, suit: .spades),
            Card(rank: .five, suit: .clubs),
            Card(rank: .six, suit: .hearts),
            Card(rank: .four, suit: .hearts),
            Card(rank: .two, suit: .diamonds)
        ]

        let expectedStraightsCount = 2
        let generatedStraights = cards.generateStraights()
        
        XCTAssertEqual(generatedStraights.count, expectedStraightsCount)
    }
    
    func testStraightsAtBoundaries() {
        let cards: Stack = [
            Card(rank: .one, suit: .clubs),
            Card(rank: .three, suit: .spades),
            Card(rank: .five, suit: .clubs),
            Card(rank: .four, suit: .hearts),
            Card(rank: .two, suit: .hearts),
        ]
        
        let cards2: Stack = [
            Card(rank: .ten, suit: .clubs),
            Card(rank: .jack, suit: .spades),
            Card(rank: .queen, suit: .clubs),
            Card(rank: .king, suit: .hearts),
            Card(rank: .ace, suit: .hearts)
        ]

        let expectedStraightsCount = 1
        let generatedStraights = cards.generateStraights()
        
        XCTAssertEqual(generatedStraights.count, expectedStraightsCount)
            
        let expectedStraightsCount2 = 1
        let generatedStraights2 = cards2.generateStraights()
        
        XCTAssertEqual(generatedStraights2.count, expectedStraightsCount2)
    }

    func testGenerateFullHouses() {
        let cards: Stack = [
            Card(rank: .three, suit: .hearts),
            Card(rank: .three, suit: .spades),
            Card(rank: .three, suit: .diamonds),
            Card(rank: .four, suit: .clubs),
            Card(rank: .four, suit: .hearts)
        ]

        let expectedFullHousesCount = 1
        let generatedFullHouses = cards.generateFullHouses()

        XCTAssertEqual(generatedFullHouses.count, expectedFullHousesCount)
    }
    
    // Test generateStairs with Phoenix
    func testGenerateStairsWithPhoenix() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .two, suit: .spades),
            Card(rank: .phoenix, suit: .diamonds), // Acts as three
            Card(rank: .three, suit: .diamonds),
            Card(rank: .four, suit: .spades)
        ]
        let generatedStairs = cards.generateStairs()

        XCTAssertEqual(generatedStairs.count, 1, "Should generate one set of stairs with Phoenix")
        XCTAssertEqual(generatedStairs.first?.count, 4, "The stairs should include 4 cards (including Phoenix)")
    }

    // Test generateStairs with broken stairs
    func testGenerateStairsWithBrokenSequence() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .four, suit: .spades),
            Card(rank: .four, suit: .clubs),
            Card(rank: .three, suit: .diamonds)
        ]
        let generatedStairs = cards.generateStairs()

        XCTAssertTrue(generatedStairs.isEmpty, "Should not generate stairs with broken sequence")
    }

    // Test generateStairs with stairs length greater than 4
    func testGenerateStairsWithLengthGreaterThanFour() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .two, suit: .spades),
            Card(rank: .three, suit: .clubs),
            Card(rank: .three, suit: .diamonds),
            Card(rank: .four, suit: .hearts),
            Card(rank: .four, suit: .spades)
        ]
        let generatedStairs = cards.generateStairs()

        XCTAssertEqual(generatedStairs.count, 3, "Should generate one set of stairs")
        XCTAssertEqual(generatedStairs[1].count, 6, "The stairs should include 6 cards")
    }

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
