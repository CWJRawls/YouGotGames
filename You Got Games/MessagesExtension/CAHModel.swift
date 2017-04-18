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
    
    
    
    
}

/* 
  CODE FOR CREATING AND MAINTAINING PLAYERS
 */

class Player {
    
    var name : String
    var id : UUID
    var hand : Hand
    var isJudge : Bool
    var handWins : Int
    
    init(name: String, hand: Hand, judge: Bool, wins: Int) {
        
    }
    
}

/* 
  CODE FOR CREATING AND MAINTAINING PLAYER HANDS
 */

class Hand {
    var cards : [Int] = [Int]()
    let maxHandSize : Int = 7
    
}

struct UsedCard {
    //which card it is
    var cardNum : [Int]
    
    //unique identifier of who played it
    var player : UUID
}

/*
  CODE FOR CREATING AND MAINTING CARD DECKS
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
