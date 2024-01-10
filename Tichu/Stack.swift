//
//  Stack.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 12/30/23.
//

import Foundation

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
