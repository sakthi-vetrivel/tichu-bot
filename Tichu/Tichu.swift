//
//  Tichu.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 12/30/23.
//
import Foundation

enum GameState {
    case ongoing
    case finished
}

struct Tichu {
    // Keep track of all cards that have been used
    private(set) var cardsPlayed: Stack
    // Keep track of the hands that have been played
    private(set) var discardedHands: [DiscardHand]
    // Players for the game
    private(set) var players: [Player]
    // Deck of cards
    private(set) var deck: Deck
    // Keep track of gamestate
    private(set) var gameState: GameState = .ongoing
    
    // Given the hand of a player, generate the CPU's hand to play
    func getCPUHand(of player: Player) -> Stack {
        let validHands = player.cards.generateAllPossibleHands()
        let sortedHandsByScore = sortHandsByScore(validHands).reversed()
        var returnHand = Stack()
        
        for hand in sortedHandsByScore {
            if playable(hand, of: player) {
                returnHand = hand
                break
            }
        }
        return returnHand
    }

    func playable(_ hand: Stack, of player: Player) -> Bool {
        var playable = false
        
        if let lastDiscardedHand = discardedHands.last {
            // If the lastDiscardedHand includes no cards, it was resetting the table, so anything is playable
            if lastDiscardedHand.hand.isEmpty {
                playable = true
            }
            else if handScore(cards: hand) > handScore(cards: lastDiscardedHand.hand) &&
                HandType(hand) == HandType(lastDiscardedHand.hand) &&
                hand.count == lastDiscardedHand.hand.count ||
                player.id == lastDiscardedHand.handOwner.id ||
                HandType(hand) == .FourOfAKindBomb || HandType(hand) == .StraightFlushBomb {
                playable = true
            }
        } else { // First hand of the game
            if hand.contains(where: { $0.rank == .one }) {
                // Play the one
                playable = true
            }
        }
        
        return playable
    }

    func handScore(cards: Stack) -> Int {
        var score = 0
        let handType = HandType(cards)

        switch handType {
        case .Single:
            if cards[0].rank == .phoenix {
                if let lastSingle = discardedHands.last?.hand.last {
                    // if the last single was a dragon, we cannot play the phoenix
                    if lastSingle.rank != .dragon {
                        score = 2*(lastSingle.rank.rawValue) + 1 //Phoenix is 0.5 higher than the previous single card played
                    }
                    else {
                        score = 0
                    }
                }
            } else {
                score = 2*cards[0].rank.rawValue
            }
        
        case .Stairs, .Straight, .Pair, .ThreeOfAKind:
            // Assuming the hand is sorted in ascending order
            if let lowestValueCard = cards.sortByRank().first {
                score = lowestValueCard.rank.rawValue * cards.count
            }

        case .FullHouse:
            let tripleRank = cards.groupedByRank().first(where: { $0.value.count == 3 })?.key
            if let tripleRank = tripleRank {
                score = tripleRank.rawValue * 3 // Modify multiplier as per game rules
            }

        case .FourOfAKindBomb:
            score = cards[0].rank.rawValue * 1000

        case .StraightFlushBomb:
            if let lowestValueCard = cards.sortByRank().first {
                score = lowestValueCard.rank.rawValue * cards.count * 1000
            }

        default:
            break // Handle other cases or do nothing
        }

        return score
    }
    
    func sortHandsByScore(_ unsortedHands: [Stack]) -> [Stack] {
        // Sort the hands based on their score in descending order
        let sortedHands = unsortedHands.sorted { handScore(cards: $0) > handScore(cards: $1) }
        return sortedHands
    }

    
    init() {
        let opponents = [
            Player(playerName: "Player1"),
            Player(playerName: "Player2")
        ]
        let partner = Player(playerName: "Player3", isPartner: true )
        let me = Player(playerName: "Me", iAmPlayer: true)
        
        players = opponents
        players.append(partner)
        players.append(me)
        
        deck = Deck()
        deck.createFullDeck()
        deck.shuffle()
        cardsPlayed = Stack()
        discardedHands = [DiscardHand]()
        
        
        let randomStartingPlayerIndex = Int(arc4random()) % players.count
        
    }
    
    mutating func checkForEndGame() -> Bool {
        let playersWithCards = players.filter { !$0.cards.isEmpty }
        return playersWithCards.count <= 1
    }

    
    mutating func dealAdditionalCards() {
        let randomStartingPlayerIndex = Int(arc4random()) % players.count
        
        while deck.cardsRemaining() > 0 {
            for p in randomStartingPlayerIndex...randomStartingPlayerIndex + (players.count - 1) {
                let i = p % players.count
                var card = deck.drawCard()
                // If I am not the player
                if players[i].iAmPlayer {
                    card.hidden = false
                }
                players[i].cards.append(card)
            }
        }

        // Sort cards in each player's hand again
        for (index, _) in players.enumerated() {
            players[index].cards = players[index].cards.sortByRank()
        }
    }
    
    mutating func dealInitialCards() {
        // Deal out the cards
        let randomStartingPlayerIndex = Int(arc4random()) % players.count
        while deck.cardsRemaining() > 56 - (players.count * 8) {
            for p in randomStartingPlayerIndex...randomStartingPlayerIndex + (players.count - 1) {
                let i = p % players.count
                var card = deck.drawCard()
                // If I am not the player
                if players[i].iAmPlayer {
                    card.hidden = false
                }
                players[i].cards.append(card)
            }
        }
        // Sort cards in each hand
        for (index, _) in players.enumerated() {
            players[index].cards = players[index].cards.sortByRank()
        }
    }

    
    mutating func select(_ card: Card, player: Player) {
        if let cardIndex = player.cards.firstIndex(where:  { $0.id == card.id}) {
            if let playerIndex = players.firstIndex(where: {$0.id == player.id}) {
                players[playerIndex].cards[cardIndex].selected.toggle()
                
            }
        }
        
    }
    
    mutating func playSelectedCard(of player: Player) {
        // Check if the card is the dog

        if let playerIndex = players.firstIndex(where: {$0.id == player.id}) {
            // First, update the 'hidden' status of the selected cards
            for i in 0..<players[playerIndex].cards.count {
                if players[playerIndex].cards[i].selected {
                    players[playerIndex].cards[i].hidden = false
                }
            }
            let playerHand = players[playerIndex].cards.filter{$0.selected == true}
            let remainingCards = players[playerIndex].cards.filter{$0.selected == false}
            // Add to set of discarded hands
            
            // Setting the hidden field to false for all played cards
            for card in playerHand {
                if let cardIndex = players[playerIndex].cards.firstIndex(where: { $0.id == card.id }) {
                    players[playerIndex].cards[cardIndex].hidden = false
                }
            }
            discardedHands.append(DiscardHand(hand: playerHand, handOwner: player))
            cardsPlayed.append(contentsOf: playerHand)
            // Update hand to reflect the cards removed
            players[playerIndex].cards = remainingCards

            // The next player is the one who played the last discarded hand
            let lastDiscardedHandOwner = discardedHands.last?.handOwner
            let lastDiscardedHandOwnerIndex = players.firstIndex(where: {$0.id == lastDiscardedHandOwner?.id})
        }
    }
    
    mutating func getNextPlayerFromCurrent() -> Player {
        var nextPlayer = Player()
        // Get playerIndex of current player
        if let currActivePlayerIndex = players.firstIndex(where: {$0.activePlayer == true}) {
            var nextPlayerIndex = (currActivePlayerIndex + 1) % players.count
            nextPlayer = players[nextPlayerIndex]
            while nextPlayer.cards.isEmpty {
               pass(nextPlayer)
               nextPlayerIndex = (nextPlayerIndex + 1) % players.count
               nextPlayer = players[nextPlayerIndex]
            }
            players[currActivePlayerIndex].activePlayer = false
        }
        return nextPlayer
    }
    
    mutating func activatePlayer(_ player: Player) {
        if let playerIndex = players.firstIndex(where:  {$0.id == player.id}) {
            players[playerIndex].activePlayer = true
        }
    }
    
    func findStartingPlayer() -> Player {
        var startingPlayer: Player!
        for aPlayer in players {
            // The player who has the one in their hand is the starting player
            if aPlayer.cards.contains(where: {$0.rank == .one} ) {
                startingPlayer = aPlayer
            }
        }
        return startingPlayer
    }
    
    mutating func pass(_ player: Player) {
        // Get the last discarded hand
        var lastDiscardedHand = discardedHands.last
        // Get the player who played the last discarded hand
        var lastDiscardedHandOwner = lastDiscardedHand?.handOwner
        // If I am three players away from the last discarded hand owner
        var myIndex = players.firstIndex(where: {$0.id == player.id})
        var lastDiscardedHandOwnerIndex = players.firstIndex(where: {$0.id == lastDiscardedHandOwner?.id})
        if myIndex == (lastDiscardedHandOwnerIndex! + 3) % players.count {
            // If the discarded hand  was not an empty placeholder and was won with the dragon
            if lastDiscardedHand?.hand.count ?? 0 > 0 && lastDiscardedHand?.hand[0].rank == .dragon {
                giveAwayDragonCards()
            }
            // All of the discarded cards go to the owner of the last discarded hand
            for discardHand in discardedHands {
                print("\(lastDiscardedHandOwner?.playerName) has won these cards: \(discardHand.hand)")
                for card in discardHand.hand {
                    players[lastDiscardedHandOwnerIndex!].cardsWon.append(card)
                }
            }
            print(player.playerName, " was the last player to pass")
            print(lastDiscardedHandOwner!.playerName, " won the hand.")
            // Reset the discardedHands, so that the next player can play anything?
            // Empty the discardedHands array
            discardedHands = []
            discardedHands.append(DiscardHand(hand: Stack(), handOwner: player))
            
            if checkForEndGame() {
                endGame()
            }
        }
    }

    // Open popup to give cards to an opponent player
    // Give cards to weak player
    func giveAwayDragonCards() {
        // Pass in the owner of the last discarded hand owner
//        if (lastDiscardedHandOwner == players.firstIndex(where: $0.iAmPlayer)) {
//        }
        return
    }

    func endGame() {
        // Tally the points of all of the players
        for player in players {
            var points = 0
            for card in player.cardsWon {
                points += card.points
            }
            print("--------------------------------------------------------------------GAME END")
            print (player.playerName, ": ", points)
        }
        // Based on the finish order, the points go to other players as well
        // Do I need to reset everything or does that happen when you start a new game
        
        // Open popup to ask to play again
        // Implement what happens when the game ends
        // This could be setting a game over flag, showing a message, etc.
    }
}

