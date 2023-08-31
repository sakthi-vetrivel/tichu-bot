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
    
    func select(_ card: Card, in player: Player) {
        model.select(card, player: player)
    }
    
    func evaluateHand(_ cards:Stack) -> HandType {
        return HandType(cards)
    }
}

