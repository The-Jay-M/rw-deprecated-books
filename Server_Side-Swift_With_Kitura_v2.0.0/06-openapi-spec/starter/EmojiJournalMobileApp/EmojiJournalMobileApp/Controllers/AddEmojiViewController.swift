/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

protocol AddEmojiDelegate: class {
  func didAdd(entry: JournalEntry, from controller: AddEmojiViewController)
}

class AddEmojiViewController: UIViewController {
  @IBOutlet weak var emojiTextField: UITextField!
  weak var delegate: AddEmojiDelegate?
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let settings = KeyboardSettings(bottomType: .categories)
    let emojiView = EmojiView(keyboardSettings: settings)
    emojiView.delegate = self
    emojiView.translatesAutoresizingMaskIntoConstraints = false
    emojiTextField.inputView = emojiView
    emojiTextField.becomeFirstResponder()
  }
}

// MARK: - AddEmojiViewController EmojiViewDelegate
extension AddEmojiViewController: EmojiViewDelegate {
  func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
    emojiTextField.text = emoji
    emojiTextField.resignFirstResponder()
  }
  
  func emojiViewDidPressDeleteButton(emojiView: EmojiView) {
    emojiTextField.text = ""
  }
}

// MARK: - AddEmojiViewController saveEmoji, displayError
extension AddEmojiViewController {
  @IBAction func saveEmoji() {
    guard let emoji = emojiTextField.text else {
      displayError(with: "Need to enter an emoji")
      return
    }
    guard let newEntry = JournalEntry(id: nil, emoji: emoji, date: Date()) else {
      displayError(with: "Could not create new entry")
      return
    }
    delegate?.didAdd(entry: newEntry, from: self)
  }
  
  private func displayError(with message: String) {
    let alert = UIAlertController(title: "Error", message: "We could not save this emoji - please try again! Reason: \(message)", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}
