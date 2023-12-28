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
    
    func testPhoenixAsLowestCardInStraight() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let cards = [Card(rank: .two, suit: .clubs), Card(rank: .three, suit: .diamonds),
                     Card(rank: .four, suit: .spades), Card(rank: .five, suit: .hearts)]
        let hand: Stack = [phoenixCard] + cards
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Straight, "Expected a straight with Phoenix as the lowest card")
    }

    func testPhoenixAsHighestCardInStraight() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let cards = [Card(rank: .six, suit: .clubs), Card(rank: .seven, suit: .diamonds),
                     Card(rank: .eight, suit: .spades), Card(rank: .nine, suit: .hearts)]
        let hand: Stack = cards + [phoenixCard]
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Straight, "Expected a straight with Phoenix as the highest card")
    }
    func testNonStraightHandWithPhoenix() {
        let phoenixCard = Card(rank: .phoenix, suit: .hearts)
        let cards = [Card(rank: .three, suit: .clubs), Card(rank: .five, suit: .diamonds),
                     Card(rank: .seven, suit: .spades), Card(rank: .nine, suit: .hearts)]
        let hand: Stack = [phoenixCard] + cards
        let handType = HandType(hand)
        XCTAssertNotEqual(handType, .Straight, "Expected not a straight with Phoenix")
    }
    
    func testLowestPossibleStraight() {
        let cards = [Card(rank: .six, suit: .clubs), Card(rank: .two, suit: .diamonds),
                     Card(rank: .three, suit: .spades), Card(rank: .four, suit: .hearts),
                     Card(rank: .five, suit: .clubs)]
        let hand: Stack = cards
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Straight, "Expected the lowest possible straight")
    }

    func testHighestPossibleStraight() {
        let cards = [Card(rank: .ten, suit: .clubs), Card(rank: .jack, suit: .diamonds),
                     Card(rank: .queen, suit: .spades), Card(rank: .king, suit: .hearts),
                     Card(rank: .ace, suit: .clubs)]
        let hand: Stack = cards
        let handType = HandType(hand)
        XCTAssertEqual(handType, .Straight, "Expected the highest possible straight")
    }
    
    func testStraightWithRepeatedRanks() {
        let cards = [Card(rank: .three, suit: .clubs), Card(rank: .three, suit: .diamonds),
                     Card(rank: .four, suit: .spades), Card(rank: .five, suit: .hearts),
                     Card(rank: .six, suit: .clubs)]
        let hand: Stack = cards
        let handType = HandType(hand)
        XCTAssertNotEqual(handType, .Straight, "Expected not a straight with repeated ranks")
    }
    
    func testStraightWithDragon() {
        let cards = [Card(rank: .dragon, suit: .clubs), Card(rank: .jack, suit: .diamonds),
                     Card(rank: .queen, suit: .spades), Card(rank: .king, suit: .hearts),
                     Card(rank: .ace, suit: .clubs)]
        let hand: Stack = cards
        let handType = HandType(hand)
        XCTAssertNotEqual(handType, .Straight, "Dragon cannot be used in a straight")
    }
    
    func testStraightWithDog() {
        let cards = [Card(rank: .dog, suit: .clubs), Card(rank: .two, suit: .diamonds),
                     Card(rank: .three, suit: .spades), Card(rank: .four, suit: .hearts),
                     Card(rank: .five, suit: .clubs)]
        let hand: Stack = cards
        let handType = HandType(hand)
        XCTAssertNotEqual(handType, .Straight, "Dog cannot be used in a straight")
    }
    
    func testValidHandTypeButNotStraight() {
        let cards = [Card(rank: .three, suit: .clubs), Card(rank: .three, suit: .diamonds),
                     Card(rank: .three, suit: .spades), Card(rank: .four, suit: .hearts),
                     Card(rank: .four, suit: .clubs)]
        let hand: Stack = cards
        let handType = HandType(hand)
        XCTAssertNotEqual(handType, .Straight, "Expected a valid hand type but not a straight")
    }
    
    // Test for a valid straight flush bomb
    func testStraightFlushBombValid() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .three, suit: .hearts),
            Card(rank: .four, suit: .hearts),
            Card(rank: .five, suit: .hearts),
            Card(rank: .six, suit: .hearts)
        ]

        let handType = HandType(cards)
        XCTAssertEqual(handType, .StraightFlushBomb, "Hand should be recognized as a Straight Flush Bomb")
    }

    // Test for an invalid straight flush bomb (just a straight)
    func testStraightFlushBombInvalidJustStraight() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .three, suit: .clubs),
            Card(rank: .four, suit: .diamonds),
            Card(rank: .five, suit: .spades),
            Card(rank: .six, suit: .hearts)
        ]

        let handType = HandType(cards)
        XCTAssertNotEqual(handType, .StraightFlushBomb, "Hand should not be recognized as a Straight Flush Bomb")
    }

    // Test for an invalid straight flush bomb (just a flush)
    func testStraightFlushBombInvalidJustFlush() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .three, suit: .hearts),
            Card(rank: .eight, suit: .hearts),
            Card(rank: .jack, suit: .hearts),
            Card(rank: .king, suit: .hearts)
        ]

        let handType = HandType(cards)
        XCTAssertNotEqual(handType, .StraightFlushBomb, "Hand should not be recognized as a Straight Flush Bomb")
    }

// Test for a regular flush (not consecutive)
    func testStraightFlushBombNonConsecutiveFlush() {
        let cards: Stack = [
            Card(rank: .two, suit: .hearts),
            Card(rank: .four, suit: .hearts),
            Card(rank: .three, suit: .hearts),
            Card(rank: .five, suit: .hearts),
            Card(rank: .ten, suit: .hearts)
        ]

        let handType = HandType(cards)
        XCTAssertNotEqual(handType, .StraightFlushBomb, "Non-consecutive flush should not be recognized as a Straight Flush Bomb")
    }
    
    // Test for a regular flush (not consecutive)
        func testStraightFlushBombAllButLast() {
            let cards: Stack = [
                Card(rank: .two, suit: .hearts),
                Card(rank: .four, suit: .hearts),
                Card(rank: .three, suit: .hearts),
                Card(rank: .five, suit: .hearts),
                Card(rank: .six, suit: .clubs)
            ]

            let handType = HandType(cards)
            XCTAssertNotEqual(handType, .StraightFlushBomb, "Non-consecutive flush should not be recognized as a Straight Flush Bomb")
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

