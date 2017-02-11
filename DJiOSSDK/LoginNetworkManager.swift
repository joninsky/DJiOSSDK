//
//  LoginNetworkManager.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation



public class LoginNetworkManager: Networker {
    
    //MARK: Functions
    public func login(withUser u: User, completion: @escaping(_ error: NetworkError?) -> Void) {
        
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("users") else {
            transaction.addErrorDescription(theError: .badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.POST)
        
        do{
            let JSON = u.getJSON()
            request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
        }catch{
            transaction.addErrorDescription(theError: .couldNotSetPOSTBody(e: error))
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }
        
        let task = self.session.dataTask(with: request) { (data, response, error) in
           
            transaction.addSessionResponse(date: data, response: response, error: error)
            
            if let e = error{
                self.mainQueue.async {
                    transaction.addErrorDescription(theError: NetworkError.requestError(e: e))
                    TransactionController.shared.addNewTransaction(transaction: transaction)
                    completion(NetworkError.requestError(e: e))
                }
            }else if let httpResponse = response as? HTTPURLResponse, let d = data {
                switch httpResponse.statusCode {
                case 200,201:
                    
                    var JSON: [String: Any]!
                    
                    do{
                        JSON = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    }catch{
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(error))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(error))
                        }
                    }
                    
                    //print(JSON)
                    
                    if let message = JSON["message"] as? String {
                        print(message)
                    }
                    
                    guard let user = JSON["user"] as? [String: Any] else {
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(nil))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(nil))
                        }
                        return
                    }
                    
                    self.mainQueue.async {
                        do{
                            try u.crackJSON(theJSON: user)
                            try User.logInUser(user: u)
                            self.mainQueue.async {
                                TransactionController.shared.addNewTransaction(transaction: transaction)
                                completion(nil)
                            }
                        }catch{
                            transaction.addErrorDescription(theError: NetworkError.realmError(e: error))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.realmError(e: error))
                        }
                    }
                    
                default:
                    self.mainQueue.async {
                        transaction.addErrorDescription(theError: .badResponse(code: httpResponse.statusCode))
                        TransactionController.shared.addNewTransaction(transaction: transaction)
                        completion(NetworkError.badResponse(code: httpResponse.statusCode))
                    }
                }
                
            }else{
                self.mainQueue.async {
                    transaction.addErrorDescription(theError: .badResponse(code: nil))
                    TransactionController.shared.addNewTransaction(transaction: transaction)
                    completion(NetworkError.badResponse(code: nil))
                }
            }
        }
        task.resume()
    }
    
    
    func updateUser(theUser u: User, updates: [String: Any], completion: @escaping (_ error: NetworkError?) -> Void) {
        
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
        
        guard let id = u.id else{
            transaction.addErrorDescription(theError: .badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("user").appendingPathComponent("\(id)") else {
            transaction.addErrorDescription(theError: .badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.PUT)
        
        do{
            let JSON = updates
            request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
        }catch{
            transaction.addErrorDescription(theError: .couldNotSetPOSTBody(e: error))
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }

        let task = self.session.dataTask(with: request) { (data, response, error) in
            
            transaction.addSessionResponse(date: data, response: response, error: error)
            
            if let e = error{
                self.mainQueue.async {
                    transaction.addErrorDescription(theError: NetworkError.requestError(e: e))
                    TransactionController.shared.addNewTransaction(transaction: transaction)
                    completion(NetworkError.requestError(e: e))
                }
            }else if let httpResponse = response as? HTTPURLResponse, let d = data {
                switch httpResponse.statusCode {
                case 200,201:
                    
                    var JSON: [String: Any]!
                    
                    do{
                        JSON = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    }catch{
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(error))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(error))
                        }
                    }
                    
                    //print(JSON)
                    
                    if let message = JSON["message"] as? String {
                        print(message)
                    }
                    
                    guard let id = JSON["id"] as? String else {
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(nil))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(nil))
                        }
                        return
                    }

                    self.mainQueue.async {
                        TransactionController.shared.addNewTransaction(transaction: transaction)
                        completion(nil)
                    }

                default:
                    self.mainQueue.async {
                        transaction.addErrorDescription(theError: .badResponse(code: httpResponse.statusCode))
                        TransactionController.shared.addNewTransaction(transaction: transaction)
                        completion(NetworkError.badResponse(code: httpResponse.statusCode))
                    }
                }
                
            }else{
                self.mainQueue.async {
                    transaction.addErrorDescription(theError: .badResponse(code: nil))
                    TransactionController.shared.addNewTransaction(transaction: transaction)
                    completion(NetworkError.badResponse(code: nil))
                }
            }
        }
        task.resume()
    }
    
    
}

