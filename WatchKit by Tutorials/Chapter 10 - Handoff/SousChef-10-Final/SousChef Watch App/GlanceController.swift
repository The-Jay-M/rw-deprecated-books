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
import SousChefKit

class GlanceController: WKInterfaceController {
  
  @IBOutlet weak var statusLabel: WKInterfaceLabel!
  @IBOutlet weak var upNextLabel: WKInterfaceLabel!
  @IBOutlet weak var onDeckLabel: WKInterfaceLabel!
  
  override func willActivate() {
    super.willActivate()
    
    // 1
    let groceryList = GroceryList().flattenedGroceries()
    
    // 2
    let items = groceryList.filter {
      $0.item is Ingredient
    }.map {
      $0.item as! Ingredient
    }
    
    // 3
    let notPurchased = items.filter {
      return $0.purchased == false
    }
    
    // 4
    let purchasedCount = items.count - notPurchased.count
    statusLabel.setText("\(purchasedCount)/\(items.count)")
    
    // 5
    if notPurchased.count > 0 {
      upNextLabel.setText(notPurchased[0].name.capitalizedString)
      
      updateUserActivity(kGlanceHandoffActivityName,
        userInfo: [kHandoffVersionKey: kHandoffVersionNumber,
          kGlanceHandoffNextItemKey: notPurchased[0].name],
        webpageURL: nil)
    }
    if notPurchased.count > 1 {
      onDeckLabel.setText(notPurchased[1].name.capitalizedString)
    }
  }

  override func didDeactivate() {
    super.didDeactivate()
    invalidateUserActivity()
  }

}
