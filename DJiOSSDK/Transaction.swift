//
//  Transaction.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift


public class Transaction: Object {
    //Meta
    public internal(set) dynamic var transactionDate: Date?
    
    public internal(set) dynamic var transactionDateString: String?
    
    //My Error Description
    public internal(set) dynamic var networkErrorDescription: String?
    //Request properties
    public internal(set) dynamic var url: String?
    
    public internal(set) dynamic var requestMethod: String?
    
    public internal(set) dynamic var headers: String?
    
    public internal(set) dynamic var postBody: String?
    //Response Properties
    public internal(set) dynamic var responseJSON: String?
    
    public internal(set) dynamic var responseStatusCode: String?
    
    public internal(set) dynamic var responseRawString: String?
    
    public internal(set) dynamic var errorRawString: String?
    
    
    internal convenience init(withDate d: Date) {
        self.init()
        self.transactionDate = d
        let dateFormat = DateFormatter()
        
        dateFormat.dateFormat = "EEE hh:mm a"
        
        self.transactionDateString = dateFormat.string(from: d)
    }
    
    
    public func getPretty() -> String {
        var string = ""
        
        if let time = self.transactionDate {
            string += "Raw Time: \(time)\n\n"
        }
        
        if let timeString = self.transactionDateString {
            string += "Human Time: \(timeString)\n\n"
        }
        
        if let description = self.networkErrorDescription {
            string += "Description: \(description)\n\n"
        }
        
        if let u = self.url {
            string += "URL: \(u)\n\n"
        }
        
        if let method = self.requestMethod {
            string += "Request Method: \(method)\n\n"
        }
        
        if let h = self.headers {
            string += "Request Headers: \(h)\n\n"
        }
        
        if let body = self.postBody {
            string += "Post Body: \(body)\n\n"
        }
        
        if let respone = self.responseJSON {
            string += "Response Body: \(respone)\n\n"
        }
        
        if let code = self.responseStatusCode {
            string += "Status Code: \(code)\n\n"
        }
        
        if let raw = self.responseRawString {
            string += "Raw URL Response: \(raw)\n\n"
        }
        
        if let error = self.errorRawString {
            string += "Returned Error: \(error)\n\n"
        }
        
        return string
    }
    
    
    
    internal func addRequest(request r: URLRequest) {
        
        self.url = r.url?.absoluteString
        
        self.requestMethod = r.httpMethod
        
        var headerString = ""
        
        if let headers = r.allHTTPHeaderFields {
            for (i, h) in headers.enumerated() {
                headerString += "\(i): \(h) "
            }
        }
        
        if !headerString.isEmpty{
            self.headers = headerString
        }
        
        if let data = r.httpBody {
            //Convert back to string. Usually only do this for debugging
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                self.postBody = JSONString
            }
        }
    }
    
    internal func addErrorDescription(theError e: NetworkError) {
        switch e {
        case .noInternet:
            self.networkErrorDescription = "Internet is unavailable"
        case .badURL:
            self.networkErrorDescription = "Failed to construct URL"
        case .badConfiguration:
            self.networkErrorDescription = "PBConfiguration not set, no PBAppID"
        case .couldNotSetPOSTBody(let error):
            self.networkErrorDescription = "Could not set JSON for request body \(error)"
        case .requestError(let error):
            self.networkErrorDescription = "The URL Session returned an error \(error)"
        case .badResponse(let code):
            self.networkErrorDescription = "Bad Request Response \(code)"
        case .failedToParseJSON:
            self.networkErrorDescription = "Faild to parse returned JSON"
        case .realmError(let error):
            self.networkErrorDescription = "There was an error saving the request to local storage \(error)"
        }
    }
    
    
    internal func addSessionResponse(date d: Data?, response r: URLResponse?, error e: Error?) {
        
        if let data = d{
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                self.responseJSON = JSONString
            }
        }
        
        if let response = r as? HTTPURLResponse{
            self.responseStatusCode = "\(response.statusCode)"
            self.responseRawString = "\(response)"
        }else if let response = r{
            self.responseRawString = "\(response)"
        }
        
        if let error = e {
            self.errorRawString = "\(error)"
        }
    }
    
    
    
    
}
