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
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: -70)]) {
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
                    ForEach(tichu.discardedHands) {
                        discardHand in LazyVGrid(columns: Array(repeating: GridItem(.fixed(100), spacing: -5), count: discardHand.hand.count)) {
                            ForEach(discardHand.hand) { card in
                                CardView(card: card)
                            }
                        }
                    }
                    let playerHand = tichu.players[3].cards.filter{$0.selected == true}
                    let handType = "\(tichu.evaluateHand(playerHand))"
                    Text(handType)
                }
                let myPlayer = tichu.players[3]
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: -70)]) {
                    ForEach(myPlayer.cards) { card in
                        CardView(card: card)
                            .offset(y: card.selected ? -30: 0)
                            .onTapGesture {
                                tichu.select(card, in: myPlayer)
                            }
                    }
                }
            }
        }
        .onAppear() {
            print("On Appear")
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
