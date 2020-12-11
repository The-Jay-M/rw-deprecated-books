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

import Foundation
import WatchKit

class KitchenTimerNotificationController: WKUserNotificationInterfaceController {

  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var messageLabel: WKInterfaceLabel!

  override func didReceiveLocalNotification(localNotification:UILocalNotification, withCompletion completionHandler:(WKUserNotificationInterfaceType)->Void) {
    if let userInfo = localNotification.userInfo {
      processNotificationWithUserInfo(userInfo, withCompletion: completionHandler)
    }
  }

  override func didReceiveRemoteNotification(remoteNotification:[NSObject : AnyObject], withCompletion completionHandler:(WKUserNotificationInterfaceType)->Void) {
    processNotificationWithUserInfo(remoteNotification, withCompletion: completionHandler)
  }

  func processNotificationWithUserInfo(userInfo: [NSObject : AnyObject], withCompletion completionHandler:(WKUserNotificationInterfaceType)->Void) {
    messageLabel.setHidden(true)
    if let message = userInfo["message"] as? String {
      messageLabel.setHidden(false)
      messageLabel.setText(message)
    }

    titleLabel.setHidden(true)
    if let title = userInfo["title"] as? String {
      titleLabel.setHidden(false)
      titleLabel.setText(title)
    }

    completionHandler(.Custom)
  }

}
