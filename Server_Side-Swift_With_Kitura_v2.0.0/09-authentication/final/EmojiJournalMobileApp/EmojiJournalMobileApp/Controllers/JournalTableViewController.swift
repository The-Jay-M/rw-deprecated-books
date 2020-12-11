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

class JournalTableViewController: UITableViewController {
  private var journalEntries: [JournalEntry] = []
  private var deleteEntryIndexPath: IndexPath?
  fileprivate var emojiSearchTextField: UITextField?
  fileprivate var idSearchTextField: UITextField?
  
  override func viewDidAppear(_ animated: Bool) {
    loadJournalEntries(with: nil)
  }
  
  @IBAction func refresh() {
    loadJournalEntries(with: nil)
  }
  
  @IBAction func search() {
    promptQueryChoices()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addNewEmojiSegue" {
      guard let addController = segue.destination as? AddEmojiViewController else {
        return
      }
      addController.delegate = self
    } else if segue.identifier == "updateEmojiSegue" {
      guard let existingEntry = sender as? JournalEntry else {
        return
      }
      guard let updateController = segue.destination as? AddEmojiViewController else {
        return
      }
      updateController.delegate = self
      updateController.existingEntry = existingEntry
    }
  }
  
  private func loadJournalEntry(id: String) {
    EmojiClient.get(id: id) { [weak self] entry, error in
      guard let strongSelf = self else {
        return
      }
      if let error = error {
        strongSelf.handleError(error)
      } else {
        strongSelf.journalEntries = [entry!]
        strongSelf.tableView.reloadData()
      }
    }
  }
  
  private func loadJournalEntries(with emoji: String?) {
    if let emoji = emoji {
      EmojiClient.get(emoji: emoji) { [weak self] entries, error in
        guard let strongSelf = self else {
          return
        }
        if let error = error {
          strongSelf.handleError(error)
        } else {
          strongSelf.journalEntries = entries!
          strongSelf.tableView.reloadData()
        }
      }
    } else {
      EmojiClient.getAll { [weak self] entries, error in
        guard let strongSelf = self else {
          return
        }
        if let error = error {
          strongSelf.handleError(error)
        } else {
          strongSelf.journalEntries = entries!
          strongSelf.tableView.reloadData()
        }
      }
    }
  }
  
  fileprivate func handleError(_ error: EmojiClientError) {
    switch error {
    case .couldNotAdd(let entry):
      UIAlertController.showError(with: "Could not add entry: \(entry.emoji)", on: self)
    case .couldNotDelete(let entry):
      UIAlertController.showError(with: "Could not delete entry: \(entry.emoji)", on: self)
    case .couldNotLoadEntries:
      UIAlertController.showError(with: "Could not access entries on server", on: self)
    case .couldNotLoadEntry(let id):
      UIAlertController.showError(with: "Could not access entry with id: \(id)", on: self)
    case .couldNotCreateClient:
      UIAlertController.showError(with: "Could not create client for server transmission", on: self)
    case .couldNotUpdate(let entry):
      UIAlertController.showError(with: "Could not update entry: \(entry.emoji)", on: self)
    case .couldNotLoadEntryWithID(let id):
      UIAlertController.showError(with: "Could not update entry with id: \(id)", on: self)
    case .couldNotLoadEntryWithEmoji(let id):
      UIAlertController.showError(with: "Could not update entry with id: \(id)", on: self)
    }
  }
}

//MARK: - UIAlertController showerror
extension UIAlertController {
  static func showError(with message: String, on controller: UIViewController) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    controller.present(alert, animated: true, completion: nil)
  }
}

// MARK: - Table view data source
extension JournalTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return journalEntries.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: JournalTableViewCell.cellIdentifier, for: indexPath) as! JournalTableViewCell
    let entry = journalEntries[indexPath.row]
    cell.emojiLabel.text = entry.emoji
    cell.dateLabel.text = entry.date.displayDate.uppercased()
    cell.timeLabel.text = entry.date.displayTime
    cell.backgroundColor = entry.backgroundColor
    return cell
  }
}


// MARK - Search Functionality
extension JournalTableViewController {
  func promptQueryChoices() {
    let alert = UIAlertController(title: "How would you like to search?", message: nil, preferredStyle: .alert)
    let idAction = UIAlertAction(title: "ID", style: .default) { action in
      self.promptIDAction()
    }
    let emojiAction = UIAlertAction(title: "Emoji", style: .default) { action in
      self.promptEmojiAction()
    }
    alert.addAction(idAction)
    alert.addAction(emojiAction)
    present(alert, animated: true, completion: nil)
  }
  
  func promptIDAction() {
    let alert = UIAlertController(title: "Enter ID to search for", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
      guard let strongSelf = self else {
        return
      }
      guard let idSearch = strongSelf.idSearchTextField?.text else {
        return
      }
      strongSelf.idSearchTextField = nil
      strongSelf.loadJournalEntry(id: idSearch)
    }))
    alert.addTextField { [weak self] textField in
      guard let strongSelf = self else {
        return
      }
      strongSelf.idSearchTextField = textField
    }
    present(alert, animated: true, completion: nil)
  }
  
  func promptEmojiAction() {
    let alert = UIAlertController(title: "Enter emoji to search for", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
      guard let strongSelf = self else {
        return
      }
      guard let emojiSearch = strongSelf.emojiSearchTextField?.text else {
        return
      }
      strongSelf.emojiSearchTextField = nil
      strongSelf.loadJournalEntries(with: emojiSearch)
    }))
    alert.addTextField { [weak self] textField in
      guard let strongSelf = self else {
        return
      }
      strongSelf.emojiSearchTextField = textField
      let settings = KeyboardSettings(bottomType: .categories)
      let emojiView = EmojiView(keyboardSettings: settings)
      emojiView.delegate = self
      emojiView.translatesAutoresizingMaskIntoConstraints = false
      textField.inputView = emojiView
      textField.becomeFirstResponder()
    }
    present(alert, animated: true, completion: nil)
  }
}

// MARK - Search Functionality Emoji Delegate
extension JournalTableViewController: EmojiViewDelegate {
  func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
    if let textField = emojiSearchTextField {
      textField.text = emoji
    }
  }
  
  func emojiViewDidPressDeleteButton(emojiView: EmojiView) {
    if let textField = emojiSearchTextField {
      textField.text = ""
    }
  }
}

// MARK: - Add Emoji Delegate functions
extension JournalTableViewController: AddEmojiDelegate {
  func didAdd(entry: JournalEntry, from controller: AddEmojiViewController) {
    EmojiClient.add(entry: entry) { [weak self] (savedEntry: JournalEntry?, error: EmojiClientError?) in
      guard let strongSelf = self else {
        return
      }
      if let error = error {
        strongSelf.handleError(error)
      } else {
        strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
        // avoid animating to top of empty table view, causing crash
        if strongSelf.tableView.numberOfRows(inSection: 0) > 0 {
          let path = IndexPath(row: 0, section: 0)
          strongSelf.tableView.scrollToRow(at: path, at: UITableView.ScrollPosition.top, animated: true)
        }
      }
    }
  }
  
  func didUpdate(entry: JournalEntry, from controller: AddEmojiViewController) {
    EmojiClient.update(entry: entry) { [weak self] updatedEntry, error in
      guard let strongSelf = self else {
        return
      }
      if let error = error {
        strongSelf.handleError(error)
      } else {
        strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
        strongSelf.loadJournalEntries(with: nil)
      }
    }
  }
}

// MARK: - Table view delegate
extension JournalTableViewController {
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let updateAction = UIContextualAction(style: .normal, title: "Update") { [weak self] action, view, Void in
      guard let strongSelf = self else {
        return
      }
      strongSelf.performSegue(withIdentifier: "updateEmojiSegue", sender: strongSelf.journalEntries[indexPath.row])
    }
    updateAction.backgroundColor = .purple
    let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] action, view, Void in
      guard let strongSelf = self else {
        return
      }
      strongSelf.deleteEntryIndexPath = indexPath
      let entry = strongSelf.journalEntries[indexPath.row]
      strongSelf.confirmDelete(entry: entry)
    }
    deleteAction.backgroundColor = .red
    let config = UISwipeActionsConfiguration(actions: [updateAction, deleteAction])
    return config
  }

  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      deleteEntryIndexPath = indexPath
      let entry = journalEntries[indexPath.row]
      confirmDelete(entry: entry)
    }
  }
  
  func confirmDelete(entry: JournalEntry) {
    let alert = UIAlertController(title: "Delete Journal Entry", message: "Are you sure you want to delete \(entry.emoji) from your journal?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: deleteEntryHandler))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
      guard let strongSelf = self else {
        return
      }
      strongSelf.deleteEntryIndexPath = nil
    }))
    present(alert, animated: true, completion: nil)
  }
  
  func deleteEntryHandler(action: UIAlertAction) {
    guard let indexPath = deleteEntryIndexPath else {
      deleteEntryIndexPath = nil
      return
    }
    EmojiClient.delete(entry: journalEntries[indexPath.row]) { [weak self] (error: EmojiClientError?) in
      guard let strongSelf = self else {
        return
      }
      if let error = error {
        strongSelf.handleError(error)
      } else {
        strongSelf.tableView.beginUpdates()
        strongSelf.journalEntries.remove(at: indexPath.row)
        strongSelf.tableView.deleteRows(at: [indexPath], with: .automatic)
        strongSelf.deleteEntryIndexPath = nil
        strongSelf.tableView.endUpdates()
      }
    }
  }
}

// MARK: - JournalEntry backgroundColor
extension JournalEntry {
  var backgroundColor: UIColor {
    guard let substring = id?.suffix(6).uppercased() else {
      return UIColor(hexString: "000000")
    }
    return UIColor(hexString: substring)
  }
}

// MARK: - UIColor hexString
extension UIColor {
  convenience init(hexString: String, alpha: CGFloat = 1.0) {
    let r, g, b: CGFloat
    let offset = hexString.hasPrefix("#") ? 1 : 0
    let start = hexString.index(hexString.startIndex, offsetBy: offset)
    let hexColor = String(hexString[start...])
    let scanner = Scanner(string: hexColor)
    var hexNumber: UInt64 = 0
    if scanner.scanHexInt64(&hexNumber) {
      r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
      g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
      b = CGFloat(hexNumber & 0x0000ff) / 255
      self.init(red: r, green: g, blue: b, alpha: alpha)
      return
    }
    self.init(red: 0, green: 0, blue: 0, alpha: alpha)
    return
  }
  
  func toHexString() -> String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
    return String(format:"#%06x", rgb)
  }
}
