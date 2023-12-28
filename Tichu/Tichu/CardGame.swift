//
//  CardGame.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 6/25/23.
//

import Foundation

enum Rank: Int, CaseIterable, Comparable {
    case dog=1, one=2, two=3, three=4, four=5, five=6, six=7, seven=8, eight=9, nine=10, ten=11, jack=12, queen=13, king=14, ace=15, phoenix=20, dragon=25
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum Suit: Int, CaseIterable, Comparable {
    case clubs=1, hearts, spades, diamonds
    static func < (lhs: Suit, rhs: Suit) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

struct Card : Identifiable {
    var rank : Rank
    var suit : Suit
    var filename : String {
        switch rank {
        case Rank.dog:
            return "dog"
        case Rank.one:
            return "one"
        case Rank.phoenix:
            return "phoenix"
        case Rank.dragon:
            return "dragon"
        default:
            return "\(suit)" + "_" + "\(rank)"
        }
    }
    var points : Int {
        switch rank {
        case Rank.five:
            return 5
        case Rank.ten:
            return 10
        case Rank.king:
            return 10
        case Rank.phoenix:
            return -25
        case Rank.dragon:
            return 25
        default:
            return 0
        }
    }
    var id = UUID()
    var selected = false
}

typealias Stack = [Card]

extension Stack where Element == Card {

    func groupedByRank() -> [Rank: [Card]] {
        return Dictionary(grouping: self, by: { $0.rank })
    }

    func sortByRank() -> Self {
        var sortedHand = Stack()
        var remainingCards = self
        
        while !remainingCards.isEmpty {
            var highestCardIndex = 0
            for i in 1..<remainingCards.count {
                if remainingCards[i].rank > remainingCards[highestCardIndex].rank
                   || (remainingCards[i].rank == remainingCards[highestCardIndex].rank
                       && remainingCards[i].suit > remainingCards[highestCardIndex].suit) {
                    highestCardIndex = i
                }
            }
            let highestCard = remainingCards.remove(at: highestCardIndex)
            sortedHand.append(highestCard)
        }
        return sortedHand
    }

    func generateAllPossibleHands() -> [Stack] {
        var possibleHands = [Stack]()
        // Add all possible single cards
        for card in self {
            possibleHands.append(Stack([card]))
        }
        possibleHands.append(contentsOf: self.generatePairsTripsFours())
        possibleHands.append(contentsOf: self.generateStraights())
        possibleHands.append(contentsOf: self.generateStairs())
        possibleHands.append(contentsOf: self.generateFullHouses())
        print(possibleHands.count)
        return possibleHands
    }

    func generatePairsTripsFours() -> [Stack] {
        var possibleCombinations = [Stack]()

        let containsPhoenix = self.contains { $0.rank == .phoenix }
        // TODO: Change this to filter out all special cards
        let nonPhoenixCards = self.filter { $0.rank != .phoenix }
        let groupedByRank = Dictionary(grouping: nonPhoenixCards, by: { $0.rank })
        var pairs = [Stack]()
        var triples = [Stack]()
        var fourOfAKind = [Stack]()

        for (_, cards) in groupedByRank {
            if cards.count >= 2 {
                for i in 0..<(cards.count - 1) {
                    for j in (i + 1)..<cards.count {
                        pairs.append([cards[i], cards[j]]) // Pairs

                        if cards.count >= 3 {
                            for k in (j + 1)..<cards.count {
                                triples.append([cards[i], cards[j], cards[k]]) // Triples

                                if cards.count == 4 {
                                for l in (k + 1)..<cards.count {
                                    fourOfAKind.append([cards[i], cards[j], cards[k], cards[l]]) // Four of a kind
                                }
                            }
                        }

                    }
                }
            }
            // Using Phoenix to complete pairs or triples
            if containsPhoenix, let phoenixCard = self.first(where: { $0.rank == .phoenix }) {
                if cards.count >= 1 {
                    // Form pairs with Phoenix
                    pairs.append([cards[0], phoenixCard])

                    if cards.count >= 2 {
                        // Form triples with Phoenix
                        for i in 0..<(cards.count - 1) {
                            for j in (i + 1)..<cards.count {
                                triples.append([cards[i], cards[j], phoenixCard])
                            }
                        }
                    }
                }
            }
        }   
     }
     // Combine all combinations
        possibleCombinations.append(contentsOf: pairs)
        possibleCombinations.append(contentsOf: triples)
        possibleCombinations.append(contentsOf: fourOfAKind)
        print(pairs)
        print(possibleCombinations)
        return possibleCombinations
    }
    func generateStraights() -> [Stack] {
        // Step 1: Generate all combinations of cards with length 5 or more
        let combinations = generateCombinations(minLength: 5)

        // Step 2: Filter combinations that form a straight
        return combinations.filter { isStraight($0) }
    }

    private func generateCombinations(minLength: Int) -> [Stack] {
        var result = [Stack]()
        var temp = Stack()

        func backtrack(start: Int) {
            if temp.count >= minLength {
                result.append(temp)
            }

            for i in start..<count {
                temp.append(self[i])
                backtrack(start: i + 1)
                temp.removeLast()
            }
        }

        backtrack(start: 0)
        return result
    }

    private func isStraight(_ stack: Stack) -> Bool {
        return (HandType(stack) == .Straight || HandType(stack) == .StraightFlushBomb)
    }


    func generateStairs() -> [Stack] {
        var possibleStairs = [Stack]()
        let containsPhoenix = self.contains { $0.rank == .phoenix }
        let nonSpecialCards = self.filter { !$0.rank.isSpecial() }
        
        let groupedByRank = Dictionary(grouping: nonSpecialCards, by: { $0.rank })

        for rank in Rank.allCases {
            var currentStairs = Stack()
            var phoenixUsed = false
            var nextRank = rank

            // Until we hit an ace
            while nextRank != .ace {
                if currentStairs.count >= 4 {
                    possibleStairs.append(currentStairs)
                }
                // Do we have cards for this rank at all?
                let cards = groupedByRank[nextRank] ?? []
                // If we have a pair, add it to the stairs
                if cards.count >= 2 {
                    currentStairs.append(contentsOf: cards)
                // Otherwise, we only have one
                } else if cards.count == 1, !phoenixUsed && containsPhoenix {
                    // Use Phoenix as a placeholder for a missing pair
                    currentStairs.append(cards[0])
                    currentStairs.append(Card(rank: .phoenix, suit: .diamonds))
                    phoenixUsed = true
                } else {
                    break
                }

                nextRank = nextRank.next()!
            }

//            if currentStairs.count >= 4 {
//                possibleStairs.append(currentStairs)
//            }
        }

        return possibleStairs
    }

    func generateFullHouses() -> [Stack] {
        var possibleFullHouses = [Stack]()
        let containsPhoenix = self.contains { $0.rank == .phoenix }
        let nonSpecialCards = self.filter { !$0.rank.isSpecial() }
        
        let groupedByRank = Dictionary(grouping: nonSpecialCards, by: { $0.rank })

        var triples = [Rank: Stack]()
        var pairs = [Rank: Stack]()

        // Find all triples and pairs
        for (rank, cards) in groupedByRank {
            if cards.count >= 3 {
                triples[rank] = Array(cards.prefix(3))
            }
            if cards.count >= 2 {
                pairs[rank] = Array(cards.prefix(2))
            }
        }

        // Use Phoenix to form triples or pairs if necessary
        if containsPhoenix {
            for (rank, cards) in groupedByRank {
                if cards.count == 2, !triples.keys.contains(rank) {
                    // Form a triple using Phoenix
                    triples[rank] = cards + [Card(rank: .phoenix, suit: .diamonds)]
                }
                if cards.count == 1, !pairs.keys.contains(rank) {
                    // Form a pair using Phoenix
                    pairs[rank] = cards + [Card(rank: .phoenix, suit: .diamonds)]
                }
            }
        }
        // Combine triples and pairs to form full houses
        for (tripleRank, triple) in triples {
            for (pairRank, pair) in pairs {
                if tripleRank != pairRank {
                    possibleFullHouses.append(triple + pair)
                }
            }
        }
        return possibleFullHouses
    }
}

extension Rank {
    func isSpecial() -> Bool {
        switch self {
        case .dog, .dragon, .phoenix, .one:
            return true
        default:
            return false
        }
    }

    func next() -> Rank? {
        // Return the next rank, excluding special ranks
        switch self {
        case .king: return .ace
        case .ace: return nil // No next rank after ace
        default: return Rank(rawValue: self.rawValue + 1)
        }
    }
}


let specialCards: [Rank] = [.dog, .dragon, .one, .phoenix]


struct Player: Identifiable, Equatable{
    var cards = Stack()
    var playerName = ""
    var iAmPlayer = false
    var isPartner = false
    var id = UUID()
    var activePlayer = false
    var cardsWon = Stack()
    
    // Conformance to Equatable
    static func ==(lhs: Player, rhs: Player) -> Bool {
        // Define what makes two Player instances "equal"
        return lhs.id == rhs.id // For example, two players are equal if their IDs are the same
    }
}

struct Deck {
    private var cards = Stack()
    mutating func createFullDeck() {
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                // Avoid special cards
                if (!specialCards.contains(rank)) {
                    cards.append(Card(rank: rank, suit: suit))
                }
            }
        }
        // Add in special cards
        for rank in specialCards {
            cards.append(Card(rank: rank, suit: Suit.diamonds))
        }
    }
    mutating func shuffle() {
        cards.shuffle()
    }
    mutating func drawCard() -> Card {
        return cards.removeLast()
    }
    func cardsRemaining () -> Int {
        return cards.count
    }

}
enum HandType {
    case Invalid, Single, Pair, ThreeOfAKind, FullHouse, Straight, Stairs, FourOfAKindBomb, StraightFlushBomb
    init(_ cards: Stack) {
        var returnType: Self = .Invalid
        var phoenix =  cards.contains(where: { $0.rank == .phoenix })
        
        if cards.count == 1 {
            returnType = .Single
        }
        
        if cards.count == 2 {
            if cards[0].rank == cards[1].rank  || phoenix {
                returnType = .Pair
            }
        }
        
        if cards.count == 3 {
            if cards[0].rank == cards[1].rank && cards[1].rank == cards[2].rank {
                returnType = .ThreeOfAKind
            }
            let pairExists = cards[0].rank == cards[1].rank || cards[1].rank == cards[2].rank
            if pairExists && phoenix {
                returnType = .ThreeOfAKind
            }
        }
        
        if cards.count == 5 {
            let sortedHand = cards.sortByRank()
            // Full house checks
            // Group the cards by rank
            var groupedByRank = Dictionary(grouping: sortedHand, by: { $0.rank })
            // If the rank counts are 3 and 2 or 2 and 3, it's a full house
            if groupedByRank.values.contains(where: { $0.count == 3 }) && groupedByRank.values.contains(where: { $0.count == 2 }) {
                returnType = .FullHouse
            }
            if groupedByRank.values.contains(where: { $0.count == 2 }) && groupedByRank.values.contains(where: { $0.count == 3 }) {
                returnType = .FullHouse
            }

            // Case handling for the phoenix
            let modifiedHand = sortedHand.filter { $0.rank != .phoenix }
            groupedByRank = Dictionary(grouping: modifiedHand, by: { $0.rank })
            // If the rank counts are 3 and 1 or 2 and 2, it's a full house
            if groupedByRank.values.contains(where: { $0.count == 3 }) && groupedByRank.values.contains(where: { $0.count == 1 }) {
                returnType = .FullHouse
            }
            if groupedByRank.values.contains(where: { $0.count == 1 }) && groupedByRank.values.contains(where: { $0.count == 3 }) {
                returnType = .FullHouse
            }
            if groupedByRank.values.contains(where: { $0.count == 2 }) && groupedByRank.values.contains(where: { $0.count == 2 }) {
                returnType = .FullHouse
            }
        }
        // Check for stairs
        if cards.count >= 4 && cards.count % 2 == 0 {
            let sortedHand = cards.sortByRank()
            var stairs = true
            for i in 0 ..< cards.count / 2  {
                if sortedHand[2*i].rank != sortedHand[2*i + 1].rank {
                    if (phoenix) {
                        phoenix = false
                    }
                    else {
                        stairs = false
                        break // Break out of the loop once we find a mismatch
                    }
                }
            }
            if stairs {
                returnType = .Stairs
            }
        }
        
        //Check for bomb
        if cards.count == 4 {
            let firstCardRank = cards[0].rank
            var pass = true
            for i in 1 ..< 4 {
                if cards[i].rank != firstCardRank {
                    pass = false
                    break // Break out of the loop once we find a mismatch
                }
            }
            if pass {
                returnType = .FourOfAKindBomb
            }
        }
        
        // Check for straight
        if cards.count >= 5 {
            var isStraight = true
            var isFlush = phoenix ? false: true
            
            // Remove special cards and sort by rank
            let sortedHand = cards.sortByRank().filter { $0.rank != .phoenix }
            if sortedHand.contains(where: { $0.rank == .dog || $0.rank == .dragon}) {
                isStraight = false
            }
            
            for i in 0 ..< sortedHand.count - 1 {
                if isFlush && (sortedHand[i].suit != sortedHand[i+1].suit) {
                    isFlush = false
                }
                if (sortedHand[i].rank.rawValue == (sortedHand[i+1].rank.rawValue + 1)) {
                    // Normal consecutive cards
                    continue
                // If there is a phoenix
                } else if (phoenix) {
                    // See if we can use it
                    
                    // Use Phoenix to fill a single gap or at the end if it's not an Ace
                    phoenix = false
                } else {
                    isStraight = false
                    break
                }
            }
            
            if isStraight {
                returnType = isFlush ? .StraightFlushBomb : .Straight
            }
        }
        
        self = returnType
    }
}

struct DiscardHand : Identifiable {
    var hand: Stack
    var handOwner: Player
    var id = UUID()
}

struct Tichu {
    // Keep track of all cards that have been used
    private(set) var cardsPlayed: Stack
    private(set) var discardedHands: [DiscardHand]
    private(set) var players: [Player]
    
    func getCPUHand(of player: Player) -> Stack {
        let validHands = player.cards.generateAllPossibleHands()
        let sortedHandsByScore = sortHandsByScore(validHands)
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
            if handScore(cards: hand) > handScore(cards: lastDiscardedHand.hand) && HandType(hand) == HandType(lastDiscardedHand.hand) && hand.count == lastDiscardedHand.hand.count
                || (player.id == lastDiscardedHand.handOwner.id)
                || (HandType(hand) == .FourOfAKindBomb || HandType(hand) == .StraightFlushBomb) {
                playable = true
            }
        }
        else { // First hand of the game
            if hand.contains(where: {$0.rank == .one}) {
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
                    score = 2*(lastSingle.rank.rawValue) + 1 //Phoenix is 0.5 higher than the previous single card played
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
        
        var deck = Deck()
        deck.createFullDeck()
        deck.shuffle()
        cardsPlayed = Stack()
        discardedHands = [DiscardHand]()
        
        
        let randomStartingPlayerIndex = Int(arc4random()) % players.count
        
        // Deal out the cards
        while deck.cardsRemaining() > 0 {
            for p in randomStartingPlayerIndex...randomStartingPlayerIndex + (players.count - 1) {
                let i = p % players.count
                let card = deck.drawCard()
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
            let playerHand = players[playerIndex].cards.filter{$0.selected == true}
            let remainingCards = players[playerIndex].cards.filter{$0.selected == false}
            print(playerHand)
            // Add to set of discarded hands
            discardedHands.append(DiscardHand(hand: playerHand, handOwner: player))
            cardsPlayed.append(contentsOf: playerHand)
            // Update hand to reflect the cards removed
            players[playerIndex].cards = remainingCards
        }
    }
    
    mutating func getNextPlayerFromCurrent() -> Player {
        var nextPlayer = Player()
        // Get playerIndex of current player
        if let currActivePlayerIndex = players.firstIndex(where: {$0.activePlayer == true}) {
            var nextPlayerIndex = (currActivePlayerIndex + 1) % players.count
            nextPlayer = players[nextPlayerIndex]
            while nextPlayer.cards.count == 0 {
                nextPlayerIndex = (currActivePlayerIndex + 1) % players.count
                nextPlayer = players[nextPlayerIndex]
            }
            players[currActivePlayerIndex].activePlayer = false
//            activatePlayer(players[nextPlayerIndex])
        }
        return nextPlayer
    }
    
    mutating func activatePlayer(_ player: Player) {
        if let playerIndex = players.firstIndex(where:  {$0.id == player.id}) {
            players[playerIndex].activePlayer = true
        
//        }
//        if !player.iAmPlayer {
//            let cpuHand = getCPUHand(of: player)
//            print("getting CPUHand")
//            print("CPUHand count: \(cpuHand.count)")
//            if cpuHand.count > 0 {
//                print("CPUHand count > 0")
//                for i in 0..<cpuHand.count {
//                    select(cpuHand[i], player: player)
//                    print(cpuHand[i].rank)
//                }
//                playSelectedCard(of: player)
//            }
//            else {
//                // THIS IS WHERE I STOPPED. PLEASE CONT FROM THIS ISSUE
//                activateNextPlayerFromCurrent()
//            }
//
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
}



