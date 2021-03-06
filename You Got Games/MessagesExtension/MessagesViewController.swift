//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Connor Rawls on 4/16/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    var minimumBots : Int = 0
    let maximumBots : Int = 8
    var botCount : Int = 0
    
    @IBOutlet var botLabel : UILabel!
    
    @IBAction func incrementBots(_ sender: UIButton) {
        if botCount < maximumBots {
            botCount += 1
            
            botLabel.text = "Bots: \(botCount)"
        }
    }
    
    @IBAction func decrementBots(_ sender: UIButton) {
        if botCount > minimumBots {
            botCount -= 1
            
            botLabel.text = "Bots: \(botCount)"
        }
    }
    
    @IBAction func createGame(_ sender: UIButton) {
        
        guard let conversation = activeConversation else {fatalError("No Active Conversation Found")}
        
        let myID = conversation.localParticipantIdentifier
        
        let remoteIDs = conversation.remoteParticipantIdentifiers
        
        var allIDs = [UUID]()
        
        allIDs.append(myID)
        allIDs.append(contentsOf: remoteIDs)
        
        let game = Game(humanPlayers: allIDs, botCount: botCount)
        
        let gameURL = game.prepareURL()
        
        let message = MSMessage()
        
        let layout = MSMessageTemplateLayout()
        layout.caption = "$\(game.getPlayers()[1].id) Let's Play"// Cards Against Humanity"
        
        message.layout = layout
        message.url = gameURL
        
        conversation.insert(message, completionHandler: {(error) in if let error = error { Swift.print(error)}})
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        super.willBecomeActive(with: conversation)
        
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        super.willTransition(to: presentationStyle)
        
        Swift.print("will transition")
        
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
        
        super.didTransition(to: presentationStyle)
        
        guard let conversation = activeConversation else { fatalError("Expected active conversation") }
        
        Swift.print("1")
        
        presentViewController(for: conversation, with: presentationStyle)
        
    }
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        
        //if we are making a new game, then don't do anything
        if presentationStyle != .compact {
            
            
            let message = conversation.selectedMessage
            
            let gameURL = message?.url
            
            if let url = gameURL {
                
                let decoder = URLDecoder(url: url)
                
                decoder.decode()
                
                guard let game = decoder.getGame() else {fatalError("Corrupt Game State URL")}
                
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "gameView") as? GameViewController else {fatalError("Unable to Create ViewController")}
                
                Swift.print(conversation.localParticipantIdentifier)
                
                Swift.print("\(conversation.localParticipantIdentifier.hashValue)")
                
                guard let myPlayer = game.getPlayer(id: conversation.localParticipantIdentifier) else {fatalError("Participant not in game")}
                
                controller.sceneType = SceneType.waiting
                
                controller.player = myPlayer
                
                addChildViewController(controller)
                
                controller.view.frame = view.bounds
                
                Swift.print(myPlayer.id.uuidString)
                

                
                view.addSubview(controller.view)
                
                NSLayoutConstraint.activate([
                    controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
                    controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
                    controller.view.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
                    controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    ])
                
                controller.didMove(toParentViewController: self)
            }
            
        }
        else { //get who all is a part of the conversation
            
            let myID = conversation.localParticipantIdentifier
            
            let remoteIDs = conversation.remoteParticipantIdentifiers
            
            var allIDs = [UUID]()
            
            allIDs.append(myID)
            allIDs.append(contentsOf: remoteIDs)
            
            //set the bot label and ensure that at least 3 players (including bots) are present
            botLabel.text = "Bots: \(botCount)"
            
            if allIDs.count < 3 {
                if botCount < 1 {
                    botCount = 1
                    botLabel.text = "Bots: 1"
                }
                
                minimumBots = 1
            }
        }
    }

}
