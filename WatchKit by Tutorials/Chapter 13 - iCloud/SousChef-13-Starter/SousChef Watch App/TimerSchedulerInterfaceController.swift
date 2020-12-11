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
import SousChefKit

class TimerSchedulerData {
  let recipe:Recipe
  let stepInstruction: String
  let timer:Int

  init(recipe: Recipe, stepInstruction: String, timer: Int) {
    self.recipe = recipe
    self.stepInstruction = stepInstruction
    self.timer = timer
  }
}

class TimerSchedulerInterfaceController: WKInterfaceController {

  @IBOutlet weak var messageLabel: WKInterfaceLabel!

  var recipe: Recipe!
  var stepInstruction: String!
  var timer: Int!

  override func awakeWithContext(context: AnyObject!) {
    if let timerSchedulerData = context as? TimerSchedulerData {
      recipe = timerSchedulerData.recipe
      stepInstruction = timerSchedulerData.stepInstruction
      timer = timerSchedulerData.timer
      messageLabel.setText("Start \(timer) minute timer?")
    }
  }

  @IBAction func startButtonTapped() {
    let userInfo: [NSObject : AnyObject] = [
      "category" : "timer",
      "timer" : timer,
      "message" : "Timer: \(stepInstruction)",
      "title" : recipe.name
    ]
    WKInterfaceController.openParentApplication(userInfo, reply: {
      (userInfo:[NSObject:AnyObject]!, error: NSError!)->Void in
      self.dismissController()
    })
  }

  @IBAction func cancelButtonTapped() {
    dismissController()
  }

}
