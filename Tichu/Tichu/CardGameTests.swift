import XCTest
@testable import Tichu

final class CardGameTests: XCTestCase {
    
    func testPlayableReturnsTrueForValidHand() {
        // Arrange
        let cardGame = CardGame()
        let hand = Stack() // Create a valid hand
        let player = Player() // Create a player
        
        // Act
        let isPlayable = cardGame.playable(hand, of: player)
        
        // Assert
        XCTAssertTrue(isPlayable)
    }
    
    func testPlayableReturnsFalseForInvalidHand() {
        // Arrange
        let cardGame = CardGame()
        let hand = Stack() // Create an invalid hand
        let player = Player() // Create a player
        
        // Act
        let isPlayable = cardGame.playable(hand, of: player)
        
        // Assert
        XCTAssertFalse(isPlayable)
    }
    
    // Add more test cases as needed
    
}