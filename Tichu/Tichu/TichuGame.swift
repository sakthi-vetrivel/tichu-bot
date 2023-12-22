//
//  TichuGame.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 6/26/23.
//

import Foundation

class TichuGame: ObservableObject {
    @Published private var model = Tichu()
    
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
    
    func activatePlayer(_ player: Player) {
        model.activatePlayer(player)
    }
    
    func activateNextPlayer() {
        model.activateNextPlayerFromCurrent()
    }
    
    func findStartingPlayer() -> Player {
        return model.findStartingPlayer()
    }
}

