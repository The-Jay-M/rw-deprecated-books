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

enum EmojiClientError: Error {
  case couldNotLoadEntries
  case couldNotAdd(JournalEntry)
  case couldNotDelete(JournalEntry)
  case couldNotCreateClient
}

// MARK: - UIApplication isDebugMode
extension UIApplication {
  var isDebugMode: Bool {
    let dictionary = ProcessInfo.processInfo.environment
    return dictionary["DEBUGMODE"] != nil
  }
}

class EmojiClient {
  private static var baseURL: String {
    return "http://localhost:8080"
  }
  
  static func getAll(completion: @escaping (_ entries: [JournalEntry]?, _ error: EmojiClientError?) -> Void) {
    completion(nil, .couldNotLoadEntries)
  }
  
  static func add(entry: JournalEntry, completion: @escaping (_ entry: JournalEntry?, _ error: EmojiClientError?) -> Void) {
    completion(nil, .couldNotAdd(entry))
  }
  
  static func delete(entry: JournalEntry, completion: @escaping (_ error: EmojiClientError?) -> Void) {
    completion(.couldNotDelete(entry))
  }
}
