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

// 1
public struct Song: Codable {
  var title: String
  var length: Double
  
  enum CodingKeys: String, CodingKey {
    case title = "songTitle"
    case length = "songLength"
  }
}

public struct Animal: Codable {
  var name: String
  var age: Int?
  var isFriendly: Bool
  var birthday: Date
  var songs: [Song]
}

// 2
let baloo = Animal(name: "Baloo",
                   age: 5,
                   isFriendly: true,
                   birthday: Date(),
                   songs: [Song(title: "The Bare Necessities", length: 180)])
let bagheera = Animal(name: "Bagheera",
                      age: nil,
                      isFriendly: true,
                      birthday: Date(),
                      songs: [Song(title: "Jungle's No Place For A Boy", length: 95)])

// 3
let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.dateEncodingStrategy = .iso8601
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

do {
  // 4
  let encodedBaloo = try encoder.encode(baloo)
  if let balooString = String(data: encodedBaloo, encoding: .utf8) {
    print(balooString)
  }
  let encodedBagheera = try encoder.encode(bagheera)
  if let bagheeraString = String(data: encodedBagheera, encoding: .utf8) {
    print(bagheeraString)
  }
  // 5
  let decodedBaloo = try decoder.decode(Animal.self, from: encodedBaloo)
  print(decodedBaloo)
  let decodedBagheera = try decoder.decode(Animal.self, from: encodedBagheera)
  print(decodedBagheera)
} catch let error {
  print("Error occurred: \(error.localizedDescription)")
}
