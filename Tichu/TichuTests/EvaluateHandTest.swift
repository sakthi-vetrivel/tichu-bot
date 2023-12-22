@testable import Tichu

//  EvaluateHandTest.swift
//  TichuTests
//
//  Created by Sakthi Vetrivel on 8/30/23.
//

import XCTest

class EvaluateHandTests: XCTestCase {
    
    func testSingleCard() {
        let singleCard = Stack(arrayLiteral: Card(rank: .eight, suit: .hearts))
        let handType = HandType(singleCard)
        XCTAssertEqual(handType, .Single, "Expected Single for single card")
    }
    
    func testPair() {
        let pair = Stack(arrayLiteral: Card(rank: .eight, suit: .hearts), Card(rank: .eight, suit: .diamonds))
        let handType = HandType(pair)
        XCTAssertEqual(handType, .Pair, "Expected Pair for two cards of the same rank")
    }
    
    // ... Add tests for other hand types like ThreeOfAKind, FullHouse, etc.
    
    func testFourOfAKindBomb() {
        let fourOfAKind = Stack(arrayLiteral: Card(rank: .eight, suit: .hearts), Card(rank: .eight, suit: .diamonds), Card(rank: .eight, suit: .clubs), Card(rank: .eight, suit: .spades))
        let handType = HandType(fourOfAKind)
        XCTAssertEqual(handType, .FourOfAKindBomb, "Expected FourOfAKindBomb for four cards of the same rank")
    }
    
    func testStraight() {
        let straight = Stack(arrayLiteral: Card(rank: .seven, suit: .hearts), Card(rank: .eight, suit: .diamonds), Card(rank: .nine, suit: .clubs), Card(rank: .ten, suit: .spades), Card(rank: .jack, suit: .hearts))
        let handType = HandType(straight)
        XCTAssertEqual(handType, .Straight, "Expected Straight for five consecutive cards")
    }
    func testStraightWithoutJack() {
        let straight = Stack(arrayLiteral: Card(rank: .seven, suit: .hearts), Card(rank: .eight, suit: .diamonds), Card(rank: .nine, suit: .clubs), Card(rank: .ten, suit: .spades), Card(rank: .six, suit: .hearts))
        let handType = HandType(straight)
        XCTAssertEqual(handType, .Straight, "Expected Straight for five consecutive cards")
    }

    func testSinglePhoenix() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let hand: Stack = [phoenixCard]
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Single, "Expected a single card hand")
    }

    func testPhoenixAsPair() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let otherCard = Card(rank: .eight, suit: .clubs)
        let hand: Stack = [phoenixCard, otherCard]
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Pair, "Expected a pair")
    }

    func testPhoenixAsThreeOfAKind() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let otherCard1 = Card(rank: .eight, suit: .clubs)
        let otherCard2 = Card(rank: .eight, suit: .diamonds)
        let hand: Stack = [phoenixCard, otherCard1, otherCard2]
        let handType = HandType(hand)
        XCTAssertEqual(handType, .ThreeOfAKind, "Expected three of a kind")
    }

    func testPhoenixInFullHouse() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let threeCard1 = Card(rank: .eight, suit: .clubs)
        let threeCard2 = Card(rank: .eight, suit: .diamonds)
        let pairCard1 = Card(rank: .nine, suit: .spades)
        let pairCard2 = Card(rank: .nine, suit: .hearts)
        let hand: Stack = [phoenixCard, threeCard1, threeCard2, pairCard1, pairCard2]
        let handType = HandType(hand)
        XCTAssertEqual(handType, .FullHouse, "Expected a full house")
    }

    func testPhoenixInStraight() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let card1 = Card(rank: .two, suit: .clubs)
        let card2 = Card(rank: .six, suit: .diamonds)
        let card3 = Card(rank: .four, suit: .spades)
        let card4 = Card(rank: .five, suit: .hearts)
        let hand: Stack = [phoenixCard, card1, card2, card3, card4]
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Straight, "Expected a straight")
    }
    
    func testPhoenixInStraightAtEnd() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let card1 = Card(rank: .two, suit: .clubs)
        let card2 = Card(rank: .three, suit: .diamonds)
        let card3 = Card(rank: .four, suit: .spades)
        let card4 = Card(rank: .five, suit: .hearts)
        let hand: Stack = [phoenixCard, card1, card2, card3, card4]
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Straight, "Expected a straight")
    }

    // This will run before each test method, you can use it for setup if needed.
    override func setUp() {
        super.setUp()
    }

    // This will run after each test method, you can use it for teardown if needed.
    override func tearDown() {
        super.tearDown()
    }
}

