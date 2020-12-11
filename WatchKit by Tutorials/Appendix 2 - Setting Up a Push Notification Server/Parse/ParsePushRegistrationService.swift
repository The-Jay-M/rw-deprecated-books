//
//  ParsePushRegistrationService.swift
//  SousChef
//
//  Created by Scott Atkinson on 1/3/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import Foundation

public class ParsePushRegistrationService: NSObject, NSURLSessionDelegate {
  
  // MARK: Properties
  private let parseApplicationID = "YOUR_PARSE_APPLICATION_ID"
  private let parseRestAPIKey = "YOUR_PARSE_REST_API_KEY"
  private let rootURL = NSURL(string: "https://api.parse.com/1/")

  private var session: NSURLSession!
  
  // MARK: Public
  public override init() {
    
    // Add the parse authentication headers to the URL Session
    let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    configuration.HTTPAdditionalHeaders = [
      "X-Parse-Application-Id": parseApplicationID,
      "X-Parse-REST-API-Key": parseRestAPIKey,
    ]

    super.init()
    session = NSURLSession(configuration: configuration)
  }
  
  public func subscribe(deviceToken: NSData, completion:((success: Bool, error: NSError?) -> Void)?) {
    // Build a JSON object that can be passed to parse
    let tokenString = stripTokenCharacters(deviceToken)
    let params = ["deviceType" : "ios",
      "deviceToken" : tokenString,
      "channels" : [""]]
    
    // Parse push registrations are represented by the "installation" object
    // Create a request for one
    if let request = self.request("installations", jsonBody: params) {
      if let session = session {
        let task = session.dataTaskWithRequest(request,
          completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // No need to do anything if there is no response handler
            if let completion = completion {
              
              // Cast the response as an HTTP response
              if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 201 {
                  completion(success: true, error: nil)
                } else {
                  completion(success: false, error: error)
                }
              }
            }
        })
        task.resume()
      }
    }
  }
  
  // MARK: Private
  
  // Create a Request with an endpoint and an object that can be serialized into JSON
  private func request (urlString: String, jsonBody: AnyObject) -> NSMutableURLRequest? {
    // Build the URL relative to the base URL
    if let url = NSURL(string: urlString, relativeToURL: rootURL) {
      let request = NSMutableURLRequest(URL: url,
        cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
        timeoutInterval: 30)
      request.HTTPMethod = "POST"
      
      // Serialize the JSON body that will be posted
      if let json = NSJSONSerialization.dataWithJSONObject(jsonBody,
        options: NSJSONWritingOptions(0),
        error: nil) {
          request.HTTPBody = json;
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      }
      return request
    }
    return nil
  }
  
  // Parse expects only alphabetical characters for the token.
  // This function strips the spaces and brackets (<>)
  private func stripTokenCharacters (rawToken:NSData) -> String {
    let rawString = rawToken.description as String
    
    var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
    var deviceTokenString: String = (rawString)
      .stringByTrimmingCharactersInSet(characterSet)
      .stringByReplacingOccurrencesOfString(" ", withString:"") as String

    return deviceTokenString
  }
}
