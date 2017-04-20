//
//  CAHModel.swift
//  You Got Games
//
//  Created by Connor Rawls on 4/17/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import Messages


class Game {
    
    var wDeck : Deck
    var bDeck : Deck
    private var players: [Player]
    private var usedCards : [UsedCard]?
    private var judgeIdx : Int
    private var currentPlayer : Int
    
    //initializer for a new game
    init(humanPlayers: [UUID], botCount: Int) {
        
        players = [Player]()
        
        for (index,p) in humanPlayers.enumerated() {
            players.append(Player(id: p, name: "Player \(index)"))
        }
        
        for i in 0...botCount {
            players.append(Bot(id: UUID(uuidString: "11111111-1111-1111-1111-11111111111\(i)")!, name: "Bot \(i)"))
        }
        
        //assign the creator to be the first judge
        judgeIdx = 0
        currentPlayer = 1
        
        wDeck = Deck(type: DeckType.white, max: 460)
        bDeck = Deck(type: DeckType.black, max: 90)
        
    }
    
    //initializer for game in progress
    init(players: [Player], wCards: [Int], bCards: [Int], uCards: [UsedCard]?, cPlayer: Int, jPlayer: Int) {
    
        wDeck = Deck(type: DeckType.white, cards: wCards)
        bDeck = Deck(type: DeckType.black, cards: bCards)
        
        self.players = players
        
        usedCards = uCards
        
        currentPlayer = cPlayer
        
        judgeIdx = jPlayer
        
    }
    
    
    //function for passing reference to the game object to each of the players so that they can play their cards
    func passGameToPlayers() {
        
        for player in players {
            player.game = self
        }
    }
    
    
    
    //called from the player class to use cards
    func playCards(cards: UsedCard) {
        
        if let _ = usedCards {
            usedCards?.append(cards)
        } else {
            usedCards = [cards]
        }
    }
    
    //method to check if the current player is the current device
    func isCurrentPlayer(id: UUID) -> Bool {
        if players[currentPlayer].id == id {
            return true
        }
        
        return false
    }
    
    //after a player has taken their turn, call this to check if the next player is a bot
    func checkNextPlayer() {
        //if they are a bot, have them take their turn
        if players[currentPlayer].isBot {
            
        } else {
            //package the current state as a url and pass it along.
        }
        
    }
    
}

/* 
 ==========================================================================================================================================
  CODE FOR CREATING AND MAINTAINING PLAYERS
 ==========================================================================================================================================
 */

class Player {
    
    var name : String
    var id : UUID
    var hand : Hand
    var isJudge : Bool
    var handWins : Int
    var game : Game? //a reference to the game object so that we can pass cards or get cards
    var isBot = false
    
    //initializer for new player
    init(id: UUID, name: String)
    {
        self.id = id
        self.name = name
        hand = Hand()
        isJudge = false
        handWins = 0
        
    }
    
    //initializer for a player in a game in progress
    required init(name: String, hand: Hand, judge: Bool, wins: Int, id: UUID) {
        
        self.name = name
        
        self.hand = hand
        
        isJudge = judge
        
        handWins = wins
        
        self.id = id
        
    }
    
    func addCard(card: Int) {
        
        hand.addCard(card: card)
        
    }
    
    //method for playing white cards, array parameter for hands where multiple cards need to be played
    func playCard(cardIndex: [Int]) {
        let play = UsedCard(cardNum: cardIndex, player: id)
        
        game?.playCards(cards: play)
        
        for i in 0...cardIndex.count {
            hand.removeCard(index: cardIndex[i])
        }
    }
    
}

//sub class of player for computer player that fills out small games
class Bot : Player {

    
    required init(name: String, hand: Hand, judge: Bool, wins: Int, id: UUID) {
        super.init(name: name, hand: hand, judge: judge, wins: wins, id: id)
        
        isBot = true
    }
    
    //initializer for new player
    override init(id: UUID, name: String)
    {
        super.init(id: id, name: name)
        isBot = true
    }
    
}

/* 
 ==========================================================================================================================================
  CODE FOR CREATING AND MAINTAINING PLAYER HANDS
 ==========================================================================================================================================
 */

class Hand {
    var cards : [Int] = [Int]()
    let maxHandSize : Int = 7
    
    //default initializer
    init() {} //just waits for cards to be added
    
    //initializer for existing hand
    init(myCards: [Int]) {
        for card in myCards {
            cards.append(card)
        }
    }
    
    func addCard(card: Int) {
        if cards.count < maxHandSize {
            cards.append(card)
        }
    }
    
    func removeCard(index: Int) {
        if index >= 0 && index < cards.count {
            cards.remove(at: index)
        }
    }
    
}



//structure to represent white cards that have been played by non-judges
struct UsedCard {
    //which card it is
    var cardNum : [Int] //intentionally left an array in the case of a multi card play
    
    //unique identifier of who played it
    var player : UUID
}

/*
 ==========================================================================================================================================
  CODE FOR CREATING AND MAINTING CARD DECKS
 ==========================================================================================================================================
 */


enum DeckType : String {
    case black = "black"
    case white = "white"
}

class Deck {
    var type : DeckType = DeckType.white
    var cards : [Int] = [0]
    var discard = [Int]()
    
    
    //creates the deck from URL Data
    init(type: DeckType, cards: [Int])
    {
        self.type = type;
        self.cards = cards
    }
    
    //creates a new deck of the specified type with the specified number of cards
    init(type: DeckType, max: Int)
    {
        self.type = type
        
        cards = [Int]()
        
        //create an ordered sequence in the deck
        for i in 0...max {
            cards.append(i)
        }
        
        //"shuffle" by randomly deciding where to move each card to
        for i in 0...cards.count {
            
            //come up with the distance to shift by
            var shift = arc4random_uniform(UInt32(cards.count))
            shift = shift - UInt32(cards.count / 2)
            
            //calculate the new position of the card in the deck
            var newPos = i + Int32(shift)
            
            //account for a possible value less than 0
            if(newPos < 0) {
                newPos = Int32(cards.count) - abs(newPos)
            }
            
            //swap data between points
            let temp = cards[i]
            cards[i] = cards[Int(newPos)]
            cards[Int(newPos)] = temp
        }
    }
    
    //DO NOT CALL WITHOUT CHECKING FIRST
    func drawCard() -> Int {
        
        let rValue = cards[0]
        
        cards.remove(at: 0)
        
        return rValue
    }
    
    //should be called before calling draw card
    func hasCards() -> Bool {
        
        if cards.count == 0 && discard.count > 0 {
            
            //call for a shuffle and return true
            reFillDeck()
            return true
        }
        else if cards.count == 0 {
            
            //we have no cards and the discard is empty, must be the black deck or a gigantic game
            return false
        }
        else {
            //we have cards to draw
            return true
        }
    }
    
    private func reFillDeck() {
        
        //create a new array
        cards = [Int]()
        
        //fill with what is in the discard pile
        for i in 0...discard.count {
            cards[i] = discard[i]
        }
        
        //"shuffle" by randomly deciding where to move each card to
        for i in 0...cards.count {
            
            //come up with the distance to shift by
            var shift = arc4random_uniform(UInt32(cards.count))
            shift = shift - UInt32(cards.count / 2)
            
            //calculate the new position of the card in the deck
            var newPos = i + Int32(shift)
            
            //account for a possible value less than 0
            if(newPos < 0) {
                newPos = Int32(cards.count) - abs(newPos)
            }
            
            //swap data between points
            let temp = cards[i]
            cards[i] = cards[Int(newPos)]
            cards[Int(newPos)] = temp
        }
        
    }
}
