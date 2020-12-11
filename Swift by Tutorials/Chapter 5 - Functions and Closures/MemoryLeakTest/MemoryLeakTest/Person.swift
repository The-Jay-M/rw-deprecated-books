//
//  Person.swift
//  MemoryLeakTest
//
//  Created by Colin Eberhardt on 10/08/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import Foundation

class Person {
  let name: String
  private var actionClosure: (() -> ())!
  
  init(name: String) {
    
    self.name = name
    
    self.actionClosure = {
      println("I am \(self.name)")
    }
  }
  
  func performAction() {
    actionClosure()
  }
  
  deinit {
    println("\(name) is being deinitialized")
  }
}