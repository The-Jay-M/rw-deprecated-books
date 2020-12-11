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
import SwiftyRequest
import LoggerAPI
import CircuitBreaker

class FortuneClient {
  
  private static var baseURL: String {
    return ProcessInfo.processInfo.environment["FORTUNESERVER"] ?? "http://yerkee.com"
  }
  
  private static var fortuneURL: String {
    return "\(baseURL)/api/fortune/all"
  }
  
  public static func getFortune(completion: @escaping
    (String?) -> Void) {
    
    let errorFortune = "No fortune is good fortune"
    let errorFallback = {(error: BreakerError, msg: String) -> Void in
      Log.error("FortuneClient fallback with \(error)")
      return completion(errorFortune)
    }
    let circuitParameters = CircuitParameters(timeout: 2000, maxFailures: 2, rollingWindow: 5000, fallback: errorFallback)
    let request = RestRequest(method: .get, url: fortuneURL)
    request.circuitParameters = circuitParameters
    request.responseObject() { (response: RestResponse<Fortune>) in
      switch response.result {
      case .success(let result):
        let fortune = result.fortune
        return completion(fortune)
      case .failure(let error):
        Log.error("FortuneClient request failed with \(error)")
        return completion(errorFortune)
      }
    }
  }
  
}

struct Fortune : Codable {
  
  let fortune : String?
  
  enum CodingKeys: String, CodingKey {
    case fortune = "fortune"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    fortune = try values.decodeIfPresent(String.self, forKey: .fortune)
  }
  
}
