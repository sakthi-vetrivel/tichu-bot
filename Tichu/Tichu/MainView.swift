//
//  MainView.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 6/25/23.
//

import SwiftUI

struct MainView: View {
   @ObservedObject var tichu = TichuGame()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ForEach(tichu.players) { player in
                    if !player.iAmPlayer {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 75), spacing: -53)]) {
                            ForEach(player.cards)  {card in
                                CardView(card: card)
                            }
                        }
                        .frame(height: geo.size.height / 6)
                    }
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.yellow)
                    VStack {
                        ZStack {
                            ForEach(tichu.discardedHands) {
                                discardHand in
                                let i = tichu.discardedHands.firstIndex(where: {$0.id == discardHand.id})
                                let lastDiscardedHand: Bool = (i == tichu.discardedHands.count - 1)
                                let previousDiscardedHand: Bool = (i == tichu.discardedHands.count - 2)
                                LazyVGrid(columns: Array(repeating: GridItem(.fixed(100), spacing: -30), count: discardHand.hand.count)) {
                                    ForEach(discardHand.hand) { card in
                                        CardView(card: card)
                                    }
                                }
                                .scaleEffect(lastDiscardedHand ? 0.8 : 0.65)
                                .opacity(lastDiscardedHand ? 1 : previousDiscardedHand ? 0.4 : 0)
                                .offset(y: lastDiscardedHand ? 0 : -40)
                            }
                        }
                        
                        let lastIndex = tichu.discardedHands.count - 1
                        if lastIndex >= 0 {
                            let playerName = tichu.discardedHands[lastIndex].handOwner.playerName
                            let playerHand = tichu.discardedHands[lastIndex].hand
                            let handType = "\(tichu.evaluateHand(playerHand))"
                            Text("\(playerName): \(handType)")
                        }
                    }
                }
                let myPlayer = tichu.players[3]
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: -69)]) {
                    ForEach(myPlayer.cards) { card in
                        CardView(card: card)
                            .offset(y: card.selected ? -30: 0)
                            .onTapGesture {
                                tichu.select(card, in: myPlayer)
                            }
                    }
                }
                Button("Next") {
                    tichu.activateNextPlayer()
                }
            }
        }
        .onAppear() {
            let playerWithOne = tichu.findStartingPlayer()
            tichu.activatePlayer(playerWithOne)
            print(playerWithOne.playerName)
        }
    }
}

struct CardView: View {
    let card : Card
    var body: some View {
        Image(card.filename)
            .resizable()
            .aspectRatio(2/3, contentMode: .fit)
            .overlay(
                Rectangle()
                    .stroke(lineWidth: 1)
                    .foregroundColor(.black)
            )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
