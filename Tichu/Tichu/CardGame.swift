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
        if (!hidden) {
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
        else {
            return "abstract_clouds"
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
    var hidden : Bool = true
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

struct DiscardHand : Identifiable {
    var hand: Stack
    var handOwner: Player
    var id = UUID()
}


