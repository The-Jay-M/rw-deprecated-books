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

import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import KituraOpenAPI

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
  let router = Router()
  let cloudEnv = CloudEnv()
  
  public init() throws {
    // Run the metrics initializer
    Persistence.setUp()
    initializeMetrics(router: router)
  }
  
  func postInit() throws {
    // Endpoints
    initializeHealthRoutes(app: self)
    initializeEntryRoutes(app: self)
    initializeUserRoutes(app: self)
    initializeWebClientRoutes(app: self)
    KituraOpenAPI.addEndpoints(to: router)
    router.get("/", handler: helloWorldHandler)
  }
  
  func helloWorldHandler(request: RouterRequest, response: RouterResponse, next: ()->()) {
    response.headers.setType(MediaType.TopLevelType.text.rawValue)
    response.send("Hello, World!")
    next()
  }
  
  public func run() throws {
    try postInit()
    Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
    Kitura.run()
  }
}
