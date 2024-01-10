//
//  MainView.swift
//  Tichu
//
//  Created by Sakthi Vetrivel on 6/25/23.
//

import SwiftUI

struct MainView: View {
   @ObservedObject var tichu = TichuGame()

   @State private var counter = 0
   @State private var buttonText = "Pass"
   // Pop up for Grand Tichu call
   @State private var showDealMoreCardsPopup = false
    
    @State private var timer: Timer.TimerPublisher? = nil
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 10) {
                ForEach(tichu.players) { player in
                    if !player.iAmPlayer {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 75), spacing: -53)]) {
                            ForEach(player.cards)  {card in
                                CardView(card: card)
                            }
                            // Add an outline if the player is the active player
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                .stroke(player.activePlayer ? Color.white : Color.clear, lineWidth: 3)
                            )
                        }
                        .frame(height: geo.size.height / 6)
                        .opacity(player.activePlayer ? 1 : 0.4)
                    }
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.gray)
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
                        
                    }
                }
                let myPlayer = tichu.players[3]
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: -69)]) {
                    ForEach(myPlayer.cards) { card in
                        CardView(card: card)
                            .offset(y: card.selected ? -30: 0)
                            .onTapGesture {
                                tichu.select(card, in: myPlayer)
                                let selectedCards = tichu.players[3].cards.filter { $0.selected }
                                if selectedCards.count > 0 && tichu.playable(selectedCards, of: myPlayer) {
                                    buttonText = "Play"
                                }
                                else {
                                    buttonText = "Pass"
                                
                            }
                        }
                    }
                }
                .disabled(!myPlayer.activePlayer)
                
                Button(buttonText) {
                    counter = 0
                    if buttonText == "Play" {
                        tichu.playSelectedCard(of: myPlayer)
                    }
                }
                .disabled(myPlayer.activePlayer ? false : true)
            }
            .background(Color.black)
            .onAppear {
               // Automatically deal initial cards and show the pop-up
               tichu.dealInitialCards()
               showDealMoreCardsPopup = true
            }
        }
        
        // When the active player is changed, we want them to play
        .onChange(of: tichu.activePlayer) { player in
            if !player.iAmPlayer {
                // Get the CPU Hand of the player
                let cpuHand = tichu.getCPUHand(of: player)
                // Play their hand or pass
                if cpuHand.count > 0 {
                    for i in 0 ... cpuHand.count - 1 {
                        tichu.select(cpuHand[i], in: player)
                    }
                    tichu.playSelectedCard(of: player)
                }
                else {
                    tichu.pass(player)
                }
            }
        }
        
        // Every second, the next computer player makes their move. We trigger this by changing the active player
        .onReceive(timer ?? Timer.publish(every: 1, on: .main, in: .common)) { time in
            var nextPlayer = Player()
            counter += 1
            
            if counter >= 1 {
                if tichu.discardedHands.count == 0 {
                    nextPlayer = tichu.findStartingPlayer()
                }
                else {
                    nextPlayer = tichu.getNextPlayer()
                }
                tichu.activatePlayer(nextPlayer)
                if nextPlayer.iAmPlayer {
                    counter = -100
                    buttonText = "Pass"
                }             
                else {
                    counter = 0
                }
            }
        }
        .overlay(
            Group {
                if showDealMoreCardsPopup {
                    DealMoreCardsPopupView(showPopup: $showDealMoreCardsPopup, dealCardsAction: {
                        tichu.dealAdditionalCards() // Assuming this method deals 6 more cards
                        // Start the timer
                        timer = Timer.publish(every: 1, on: .main, in: .common)
                        timer?.connect()
                    })
                }
            }
        )
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

struct DealMoreCardsPopupView: View {
    @Binding var showPopup: Bool
    var dealCardsAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Grand?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)

            Divider()

            Button(action: {
                dealCardsAction()
                withAnimation {
                    showPopup = false
                }
            }) {
                Text("Grand!")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }

            Button(action: {
                dealCardsAction()
                withAnimation {
                    showPopup = false
                }
            }) {
                Text("No")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .frame(width: 300, height: 200)
        .background(Color(.systemBackground)) // Adapts to light/dark mode
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.scale)
    }
}

// Tichu Bet view

// Dragon Cards view

// Game End View



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
func calculateSpacing(cardWidth: CGFloat, cardCount: Int, in availableWidth: CGFloat) -> CGFloat {
    let totalCardWidth = cardWidth * CGFloat(cardCount)
    let totalSpacingWidth = availableWidth - totalCardWidth
    let numberOfGaps = CGFloat(cardCount - 1)
    
    return max(0, totalSpacingWidth / numberOfGaps) // Ensure spacing is not negative
}
