//
//  TichuGame.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 6/26/23.
//

import Foundation

class TichuGame: ObservableObject {
    @Published private var model = Tichu()
    @Published private(set) var activePlayer = Player()
    
    var players: [Player] {
        return model.players
    }
    
    var discardedHands: [DiscardHand] {
        return model.discardedHands
    }
    
    func select(_ card: Card, in player: Player) {
        model.select(card, player: player)
    }
    
    func evaluateHand(_ cards:Stack) -> HandType {
        return HandType(cards)
    }
    
    func playable(_ hand: Stack, of player: Player) -> Bool {
        return model.playable(hand, of: player)
    }
    
    func activatePlayer(_ player: Player) {
        model.activatePlayer(player)
        if let activePlayerIndex = players.firstIndex(where: {$0.activePlayer == true }) {
            activePlayer = players[activePlayerIndex]
        }
    }
    
    func getNextPlayer() -> Player {
        model.getNextPlayerFromCurrent()
    }
    
    func findStartingPlayer() -> Player {
        return model.findStartingPlayer()
    }
    
    func getCPUHand(of player: Player) -> Stack {
        return model.getCPUHand(of: player)
    }
    
    func playSelectedCard(of player: Player) {
        model.playSelectedCard(of: player)
    }
}

