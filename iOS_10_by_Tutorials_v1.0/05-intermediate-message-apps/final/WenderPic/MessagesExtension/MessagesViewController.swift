/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
  
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
    presentViewController(forConversation: conversation, withPresentationStyle: presentationStyle)
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
    if let conversation = activeConversation {
      presentViewController(forConversation: conversation,
                            withPresentationStyle: presentationStyle)
    }
  }
  
  override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
  }
  
}

// MARK: Child View Controllers
extension MessagesViewController {
  func presentViewController(forConversation conversation: MSConversation, withPresentationStyle style: MSMessagesAppPresentationStyle) {
    let controller: UIViewController
    
    switch style {
    case .compact:
      controller = instantiateSummaryViewController(game: nil)
    case .expanded:
      if let game = WenderPicGame(message: conversation.selectedMessage) {
        switch game.gameState {
        case .guess:
          controller = instantiateDrawingViewController(game: game)
        case .challenge:
          controller = instantiateGuessViewController(game: game)
        }
      } else {
        let newGame = WenderPicGame.newGame(
          drawerId: conversation.localParticipantIdentifier)
        controller = instantiateDrawingViewController(game: newGame)
      }
    }
    switchTo(viewController: controller)
  }
  
  func instantiateSummaryViewController(game: WenderPicGame?) -> UIViewController {
    guard let controller = storyboard?.instantiateViewController(withIdentifier: "summaryVC") as? SummaryViewController else { fatalError("Unable to instantiate a summary view controller") }
    
    controller.game = game
    controller.delegate = self
    return controller
  }
  
  func instantiateDrawingViewController(game: WenderPicGame?) -> UIViewController {
    guard let controller = storyboard?.instantiateViewController(withIdentifier: "drawingVC") as? DrawingViewController else { fatalError("Unable to instantiate a drawing view controller") }
    controller.delegate = self
    controller.game = game
    return controller
  }
  
  func instantiateGuessViewController(game: WenderPicGame?) -> UIViewController {
    guard let controller = storyboard?.instantiateViewController(withIdentifier: "guessVC") as? GuessViewController else { fatalError("Unable to instantiate a guess view controller") }
    controller.delegate = self
    controller.game = game
    return controller
  }
  
  
  func switchTo(viewController controller: UIViewController) {
    // Remove any existing child view controller
    for child in childViewControllers {
      child.willMove(toParentViewController: .none)
      child.view.removeFromSuperview()
      child.removeFromParentViewController()
    }
    
    // Add the new child view controller
    addChildViewController(controller)
    
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(controller.view)
    
    NSLayoutConstraint.activate([
      controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      controller.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
      controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
    
    controller.didMove(toParentViewController: self)
  }
}

extension MessagesViewController {
  func composeMessage(with game: WenderPicGame,
                              caption: String, session: MSSession? = .none) -> MSMessage {
    //1
    let layout = MSMessageTemplateLayout()
    //2
    layout.image = game.currentDrawing
    //3
    layout.caption = caption
    //4
    let message = MSMessage(session: session ?? MSSession())
    message.layout = layout
    
    var components = URLComponents()
    components.queryItems = game.queryItems
    message.url = components.url
    return message
  }
}

extension MessagesViewController: DrawingViewControllerDelegate {
  func handleDrawingComplete(game: WenderPicGame?) {
    defer { dismiss() }
    guard
      let conversation = activeConversation,
      let game = game
    else { return }
    
    let message = composeMessage(with: game, caption: "Guess my WenderPic!", session: conversation.selectedMessage?.session!)
    
    if let drawing = game.currentDrawing {
      DrawingStore.store(image: drawing, forUUID: game.gameId)
    }
    
    conversation.insert(message) { (error) in
      if let error = error {
        print(error)
      }
    }
  }
}

extension MessagesViewController: SummaryViewControllerDelegate {
  func handleSummaryTap(forGame game: WenderPicGame?) {
    requestPresentationStyle(.expanded)
  }
}

extension MessagesViewController: GuessViewControllerDelegate {
  func handleGuessSubmission(forGame game: WenderPicGame, guess: String) {
    defer { dismiss() }
    guard let conversation = activeConversation else { return }
    
    let prefix = game.check(guess: guess) ? "👍" : "👎"
    let guesser = "$\(conversation.localParticipantIdentifier)"
    
    let caption = "\(prefix) \(guesser) guessed \(guess)"
    
    let message = composeMessage(with: game,
      caption: caption,
      session: conversation.selectedMessage?.session)
    
    conversation.insert(message) { (error) in
      if let error = error {
        print(error)
      }
    }
  }
}

