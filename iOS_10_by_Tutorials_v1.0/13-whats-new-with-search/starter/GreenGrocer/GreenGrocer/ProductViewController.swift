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

let productActivityName = "com.razeware.GreenGrocer.product"

class ProductViewController: UIViewController {
  
  @IBOutlet weak var productImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var detailsLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  var product: Product? {
    didSet {
      updateViewForProduct()
      userActivity?.needsSave = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateViewForProduct()
    userActivity = prepareUserActivity()
  }

  fileprivate func updateViewForProduct() {
    if let product = product {
      productImageView?.image = UIImage(named: product.photoName)
      nameLabel?.text = product.name
      detailsLabel?.text = product.details
      priceLabel?.text = "$\(product.price)"
    }
  }
}

extension ProductViewController {
  override func updateUserActivityState(_ activity: NSUserActivity) {
    if let product = product {
      activity.contentAttributeSet = product.searchableAttributeSet
      activity.contentAttributeSet?.relatedUniqueIdentifier = product.id.uuidString
      activity.title = product.name
      activity.addUserInfoEntries(from: ["id": product.id.uuidString])
      activity.keywords = Set([product.name, "fruit"])
    }
  }
  
  fileprivate func prepareUserActivity() -> NSUserActivity {
    let activity = NSUserActivity(activityType: productActivityName)
    activity.isEligibleForHandoff = true
    activity.isEligibleForPublicIndexing = true
    activity.isEligibleForSearch = true
    return activity
  }
}
