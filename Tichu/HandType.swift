//
//  HandType.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 12/30/23.
//

import Foundation

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
                    if (i < sortedHand.count - 1) {
                        // Is there a one card gap?
                        if (sortedHand[i].rank.rawValue == (sortedHand[i+1].rank.rawValue + 2)) {
                            phoenix = false
                        }
                        else {
                            isStraight = false
                            break
                        }
                    }
                    else { 
                        // Using phoenix as last card in the straight
                        phoenix = false
                    }
                    // Use Phoenix to fill a single gap or at the end if it's not an Ace
                    
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
