/*
* Copyright (c) 2015 Razeware LLC
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

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

  @IBOutlet weak var label: WKInterfaceLabel!

  let people = ["😄", "😙", "😔", "😣", "😕", "👯", "💁"]
  let nature = ["🐣", "🍀", "🌺", "🌴", "⛅️", "🐋", "🐺"]
  let objects = ["🎁", "⏳", "🍎", "🎵", "💰", "⌚️"]
  let places = ["✈️", "♨️", "🎭", "🚲", "🎢"]
  let symbols = ["🔁", "🔀", "⏩", "⏪", "🆒"]

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    // Configure interface objects here.
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()

    // 1
    let peopleIndex = Int(arc4random_uniform(UInt32(people.count)))
    let natureIndex = Int(arc4random_uniform(UInt32(nature.count)))
    let objectsIndex = Int(arc4random_uniform(UInt32(objects.count)))
    let placesIndex = Int(arc4random_uniform(UInt32(places.count)))
    let symbolsIndex = Int(arc4random_uniform(UInt32(symbols.count)))
    
    // 2
    label.setText("\(people[peopleIndex])\(nature[natureIndex])\(objects[objectsIndex])\(places[placesIndex])\(symbols[symbolsIndex])")
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

}
