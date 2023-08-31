//
//  CardGame.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 6/25/23.
//

import Foundation

enum Rank: Int, CaseIterable, Comparable {
    case dog=1, one=2, two=3, three=4, four=5, five=6, six=7, seven=8, eight=9, nine=10, ten=11, jack=12, queen=13, king=14, ace=15, phoenix=16, dragon=17
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
            // TODO: needs to point to filenames of assets
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
        print(sortedHand)
        return sortedHand
    }
}


let specialCards: [Rank] = [.dog, .dragon, .one, .phoenix]


struct Player: Identifiable{
    var cards = Stack()
    var iAmPlayer = false
    var isPartner = false
    var id = UUID()
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
            var pairExists = cards[0].rank == cards[1].rank || cards[1].rank == cards[2].rank
            if pairExists && phoenix {
                returnType = .ThreeOfAKind
            }
        }
        
        if cards.count == 5 {
            let sortedHand = cards.sortByRank()
            // Full house checks
            let firstThreeCardsMatch = sortedHand[0].rank == sortedHand[1].rank && sortedHand[1].rank == sortedHand[2].rank
            let lastTwoCardsMatch = sortedHand[3].rank == sortedHand[4].rank
            let firstTwoCardsMatch = sortedHand[0].rank == sortedHand[1].rank
            let lastThreeCardsMatch = sortedHand[2].rank == sortedHand[3].rank && sortedHand[3].rank == sortedHand[4].rank
            
            if (firstThreeCardsMatch && lastTwoCardsMatch) || (firstTwoCardsMatch && lastThreeCardsMatch) {
                returnType = .FullHouse
            }
            // Case handling for the phoenix
            let modifiedHand = sortedHand.filter { $0.rank != .phoenix }
            let firstPair = modifiedHand[0].rank == modifiedHand[1].rank
            let secondPair = modifiedHand[2].rank == modifiedHand[3].rank
            let twoPairsExist = firstPair && secondPair
            if twoPairsExist && phoenix {
                returnType = .FullHouse
            }
        }
        // Check for stairs
        if cards.count >= 4 && cards.count % 2 == 0 {
            print("Check if stairs")
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
            print("Check if four of a kind")
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
            print("Check if straight")
            let sortedHand = cards.sortByRank()
            var isFlush = true
            var isStraight = true
            
            for i in 0 ..< cards.count - 1 {
                if sortedHand[i].suit != sortedHand[i+1].suit {
                    isFlush = false
                }
                print (sortedHand[i].rank.rawValue + 1)
                print (sortedHand[i+1].rank.rawValue)
                if sortedHand[i].rank.rawValue != sortedHand[i+1].rank.rawValue + 1 {
                    if (phoenix) {
                        phoenix = false
                    }
                    else {
                        isStraight = false
                        print("Breaking out of straight check with card", sortedHand[i].rank)
                        break // Break out of the loop once we find a mismatch
                    }
                }
            }
            
            if isStraight {
                returnType = isFlush ? .StraightFlushBomb : .Straight
            }
        }
        
        self = returnType
    }
}




struct Tichu {
    private(set) var players: [Player]
    
    init() {
        let opponents = [
            Player(),
            Player()
        ]
        let partner = Player(isPartner: true)
        let me = Player(iAmPlayer: true)
        
        players = opponents
        players.append(partner)
        players.append(me)
        
        var deck = Deck()
        deck.createFullDeck()
        deck.shuffle()
        
        let randomStartingPlayerIndex = Int(arc4random()) % players.count
        
        while deck.cardsRemaining() > 0 {
            for p in randomStartingPlayerIndex...randomStartingPlayerIndex + (players.count - 1) {
                let i = p % players.count
                let card = deck.drawCard()
                players[i].cards.append(card)
            }
        }
        for (index, _) in players.enumerated() {
            players[index].cards = players[index].cards.sortByRank()
        }
    }
    
    mutating func select(_ card: Card, player: Player) {
        if let cardIndex = player.cards.firstIndex(where:  { $0.id == card.id}) {
            if let playerIndex = players.firstIndex(where: {$0.id == player.id}) {
                players[playerIndex].cards[cardIndex].selected.toggle()            }
        }
        
    }
}

var testCards = [
    Card(rank: .dog, suit: .spades),
    Card(rank: .ten, suit: .hearts),
    Card(rank: .two, suit: .diamonds)]

var testPlayers = [
    Player(cards: testCards),
    Player(cards: testCards),
    Player(cards: testCards),
    Player(cards: testCards, iAmPlayer: true)]



