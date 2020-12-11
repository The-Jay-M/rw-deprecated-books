//
//  ReportInterfaceController.swift
//  SousChef
//
//  Created by temporary on 3/12/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import WatchKit
import Foundation


class ReportInterfaceController: WKInterfaceController {
  
  let greeting =
NSLocalizedString("greetingLabelText",
  comment: "Top of report")

  @IBOutlet weak var reportLabel: WKInterfaceLabel!
  @IBOutlet weak var greetingLabel: WKInterfaceLabel!
  
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
      
      greetingLabel.setText(greeting)
      /*
      // 1
      let totalGroceries = 10_000
      // 2
      let quantityReport = NSString(
        format: NSLocalizedString("reportLabelText",
          comment: "Full groceries report summary"),
        // 3
        String(totalGroceries))
      // 4
      reportLabel.setText(quantityReport)
      */
      let totalGroceries = 10_000
      let numberFormatter = NSNumberFormatter()
      numberFormatter.numberStyle = .DecimalStyle
      if let numberString = numberFormatter.stringFromNumber(totalGroceries) {
        let quantityReport = NSString(
          format: NSLocalizedString("reportLabelText",
            comment: "Full groceries report summary"),
          numberString)
        reportLabel.setText(quantityReport as String)
      }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
