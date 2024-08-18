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
    // Keep track of player finish order
    private(set) var finishedPlayerOrder: [Player] = []
    
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
        let type = HandType(hand)
        if type == .Invalid {
             return false
        }
        
        // Check if the player has the "one" card
        let hasOneCard = player.cards.contains(where: { $0.rank == .one })
        if hasOneCard {
            // If the player has the "one" card, they must play at least one card, so any hand is playable
            return !hand.isEmpty
        }
        
        if let lastDiscardedHand = discardedHands.last {
            // If the lastDiscardedHand includes no cards, it was resetting the table, so anything is playable
            if lastDiscardedHand.hand.isEmpty {
                return true
            }
            else if handScore(cards: hand) > handScore(cards: lastDiscardedHand.hand) &&
                HandType(hand) == HandType(lastDiscardedHand.hand) &&
                hand.count == lastDiscardedHand.hand.count ||
                player.id == lastDiscardedHand.handOwner.id ||
                HandType(hand) == .FourOfAKindBomb || HandType(hand) == .StraightFlushBomb {
                return true
            }
       }
        return false
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
                        if lastSingle.rank != .phoenix {
                            score = 2*(lastSingle.rank.rawValue) + 1 //Phoenix is 0.5 higher than the previous single card played
                        }
                        // The last single was the phoenix, and we are trying to see if a card can be played on top of it
                        else {
                            // If this phoenix was played on top of another card
                            if discardedHands.count > 1 {
                                if let lastSingle = discardedHands[discardedHands.count - 2].hand.last {
                                    score = 2*(lastSingle.rank.rawValue) + 1
                                }
                            }
                            // Otherwise, the phoenix was played on an empty playing field
                            else {
                                score = 1
                            }
                        }
                    }
                    // The last single was a dragon, so we want to calculate a low score to show that nothing can be played on the dragon
                    else {
                        score = 0
                    }
                }
            // If none of the special cases apply
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
            Player(playerName: "Alex"),
            Player(playerName: "Chris")
        ]
        let partner = Player(playerName: "Becky", isPartner: true )
        let me = Player(playerName: "Me", iAmPlayer: true)
        
        players = [opponents[0]]
        players.append(partner)
        players.append(opponents[1])
        players.append(me)
        
        deck = Deck()
        deck.createFullDeck()
        deck.shuffle()
        cardsPlayed = Stack()
        discardedHands = [DiscardHand]()
        
    }
    
    mutating func checkForEndGame() -> Bool {
        let playersWithCards = players.filter { !$0.cards.isEmpty }

        switch playersWithCards.count {
        case 1:
            return true
        case 2:
            let teamIndices = playersWithCards.compactMap { players.firstIndex(of: $0) }
            return (teamIndices.allSatisfy { $0 == 1 || $0 == 3 }) || (teamIndices.allSatisfy { $0 == 0 || $0 == 2 })
        default:
            return false
        }
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

        if let playerIndex = players.firstIndex(where: {$0.id == player.id}) {
            // First, update the 'hidden' status of the selected cards
            for i in 0..<players[playerIndex].cards.count {
                if players[playerIndex].cards[i].selected {
                    players[playerIndex].cards[i].hidden = false
                }
            }
            let playerHand = players[playerIndex].cards.filter{$0.selected == true}
            let remainingCards = players[playerIndex].cards.filter{$0.selected == false}
            
            // Setting the hidden field to false for all played cards
            for card in playerHand {
                if let cardIndex = players[playerIndex].cards.firstIndex(where: { $0.id == card.id }) {
                    players[playerIndex].cards[cardIndex].hidden = false
                }
            }
            // Add to set of discarded hands
            discardedHands.append(DiscardHand(hand: playerHand, handOwner: player))
            cardsPlayed.append(contentsOf: playerHand)
            // Update hand to reflect the cards removed
            players[playerIndex].cards = remainingCards

            // Check if the player has finished
            if players[playerIndex].cards.isEmpty && !finishedPlayerOrder.contains(where: { $0.id == player.id }) {
                finishedPlayerOrder.append(players[playerIndex])
            }
            
        }
    }
    
    mutating func getNextPlayerFromCurrent() -> Player {
        var nextPlayer = Player()
        // Get playerIndex of current player
        if let currActivePlayerIndex = players.firstIndex(where: {$0.activePlayer == true}) {
            
            let currentPlayer = players[currActivePlayerIndex]
            if let lastDiscardedHand = discardedHands.last,
               // Check if the current player played the Dog card
               lastDiscardedHand.hand.contains(where: { $0.rank == Rank.dog }) {
                // Dog card was played, pass turn to partner
                let partnerIndex = (currActivePlayerIndex + 2) % players.count
                nextPlayer = players[partnerIndex]
                
                // We model this pass as the partner winning the trick
                // Reset the discardedHands, so that the next player can play anything
                // Empty the discardedHands array
                discardedHands = []
                discardedHands.append(DiscardHand(hand: Stack(), handOwner: nextPlayer))
            } else {
                // Normal turn progression
                var nextPlayerIndex = (currActivePlayerIndex + 1) % players.count
                nextPlayer = players[nextPlayerIndex]
                while nextPlayer.cards.isEmpty {
                    pass(nextPlayer)
                    nextPlayerIndex = (nextPlayerIndex + 1) % players.count
                    nextPlayer = players[nextPlayerIndex]
                }
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
        let lastDiscardedHand = discardedHands.last
        // Get the player who played the last discarded hand
        let lastDiscardedHandOwner = lastDiscardedHand?.handOwner
        // If I am three players away from the last discarded hand owner
        let myIndex = players.firstIndex(where: {$0.id == player.id})
        let lastDiscardedHandOwnerIndex = players.firstIndex(where: {$0.id == lastDiscardedHandOwner?.id})
        if myIndex == (lastDiscardedHandOwnerIndex! + 3) % players.count {
            // If the discarded hand  was not an empty placeholder and was won with the dragon
            if lastDiscardedHand?.hand.count ?? 0 > 0 && lastDiscardedHand?.hand[0].rank == .dragon {
                giveAwayDragonCards()
            }
            // All of the discarded cards go to the owner of the last discarded hand
            for discardHand in discardedHands {
                print("\(String(describing: lastDiscardedHandOwner?.playerName ?? "Unknown")) has won these cards: \(discardHand.hand)")
                for card in discardHand.hand {
                    players[lastDiscardedHandOwnerIndex!].cardsWon.append(card)
                }
            }
            // Reset the discardedHands, so that the next player can play anything
            // Empty the discardedHands array
            discardedHands = []
            discardedHands.append(DiscardHand(hand: Stack(), handOwner: player))
            
            if checkForEndGame() {
                endGame()
            }
        }
    }
    
    mutating func handleDogCard(player: Player) {
        // Find the partner of the player who played the Dog card
        if let playerIndex = players.firstIndex(where: { $0.id == player.id }) {
            let partnerIndex = (playerIndex + 2) % players.count
            // Set the partner as the next active player
            players[playerIndex].activePlayer = false
            players[partnerIndex].activePlayer = true
            print("\(player.playerName) played the dog card. \(players[partnerIndex].playerName) is now the active player.")
        }
    }

    func findPartner(of player: Player) -> Player {
        // Find the partner of the given player
        // The partner is the player two indices apart from this player
        let playerIndex = players.firstIndex(where: {$0.id == player.id})
        let partnerIndex = (playerIndex! + 2) % players.count
        return players[partnerIndex]
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
        var team1Points = 0
        var team2Points = 0

        // Calculate points for finishing order
        let team1FinishedFirstAndSecond = finishedPlayerOrder.prefix(2).allSatisfy { player in
            guard let index = players.firstIndex(of: player) else { return false }
            return index == 1 || index == 3
        }
        
        let team2FinishedFirstAndSecond = finishedPlayerOrder.prefix(2).allSatisfy { player in
            guard let index = players.firstIndex(of: player) else { return false }
            return index == 0 || index == 2
        }

        // If a team finishes 1-2, award points accordingly
        if team1FinishedFirstAndSecond {
            team1Points = 200 + pointsForFirstPlayer(finishedPlayerOrder.first)
        } else if team2FinishedFirstAndSecond {
            team2Points = 200 + pointsForFirstPlayer(finishedPlayerOrder.first)
        } else {
            // Calculate base card points and apply Tichu/Grand Tichu points
            for player in players {
                let points = basePoints(for: player) + tichuPoints(for: player, finishOrder: finishedPlayerOrder)
                if isTeam1Player(player) {
                    team1Points += points
                } else {
                    team2Points += points
                }
            }
            // Handle points in hand of the last player
            if let lastPlayer = finishedPlayerOrder.last {
                let lastPlayerPoints = lastPlayer.cards.reduce(0) { $0 + $1.points }
                
                // Add these points to the opposite team
                if [1, 3].contains(players.firstIndex(of: lastPlayer)) { // Last player was on Team 1
                    team2Points += lastPlayerPoints
                } else { // Last player was on Team 2
                    team1Points += lastPlayerPoints
                }
            }
        }

        // Display final team scores
        displayFinalScores(team1Points: team1Points, team2Points: team2Points)
    }

    private func pointsForFirstPlayer(_ player: Player?) -> Int {
        guard let player = player else { return 0 }
        if player.declaredGrandTichu {
            return 200
        } else if player.declaredTichu {
            return 100
        }
        return 0
    }

    private func basePoints(for player: Player) -> Int {
        return player.cardsWon.reduce(0) { $0 + $1.points }
    }

    private func tichuPoints(for player: Player, finishOrder: [Player]) -> Int {
        guard let finishedIndex = finishOrder.firstIndex(of: player) else { return 0 }
        
        if finishedIndex == 0 {
            // Bonus points for finishing first with Tichu or Grand Tichu
            return player.declaredGrandTichu ? 200 : (player.declaredTichu ? 100 : 0)
        } else if player.declaredTichu || player.declaredGrandTichu {
            // Deduction for not finishing first with a Tichu or Grand Tichu declaration
            return player.declaredGrandTichu ? -200 : -100
        }
        return 0
    }

    private func isTeam1Player(_ player: Player) -> Bool {
        guard let index = players.firstIndex(of: player) else { return false }
        return index == 1 || index == 3
    }

    private func displayFinalScores(team1Points: Int, team2Points: Int) {
        print("Team 1 Total Points: \(team1Points)")
        print("Team 2 Total Points: \(team2Points)")

        let winningTeam = team1Points > team2Points ? "Team 1" : "Team 2"
        print("\(winningTeam) wins the game!")
    }

}

