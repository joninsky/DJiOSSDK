//
//  PartyNetworkManager.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

class PartyNetworkManager: Networker {
    
    
    func createParty(party p: Party, byUser u: User, completion: @escaping(_ error: NetworkError?) -> Void) {
        
        let transaction = Transaction(withDate: Date())
        
//        guard Configuration.internetStatus != .notReachable else{
//            transaction.addErrorDescription(theError: NetworkError.noInternet)
//            TransactionController.shared.addNewTransaction(transaction: transaction)
//            completion(NetworkError.noInternet)
//            return
//        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party") else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = URLRequest(url: finalURL)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue(contentTypeValue, forHTTPHeaderField: contentTypeHeader)
        
        do{
            var JSON = p.getJSON()
            JSON[PartyJSON.dj.rawValue] = u.id
            request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
        }catch{
            transaction.addErrorDescription(theError: NetworkError.couldNotSetPOSTBody(e: error))
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
                    
                    if let message = JSON["message"] as? String {
                        print(message)
                    }
                    
                    
                    print(JSON)
                    
                    guard let id = JSON["id"] as? String else {
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(nil))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(nil))
                        }
                        return
                    }
                    
                    print(id)
                    
                    self.mainQueue.async {
                        do{
                            try p.bindID(id)
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(nil)
                        }catch{
                            transaction.addErrorDescription(theError: NetworkError.realmError(e: error))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.realmError(e: error))
                        }
                    }
                    
                default:
                    self.mainQueue.async {
                        transaction.addErrorDescription(theError: NetworkError.badResponse(code: httpResponse.statusCode))
                        TransactionController.shared.addNewTransaction(transaction: transaction)
                        completion(NetworkError.badResponse(code: httpResponse.statusCode))
                    }
                }
                
            }else{
                self.mainQueue.async {
                    transaction.addErrorDescription(theError: NetworkError.badResponse(code: nil))
                    TransactionController.shared.addNewTransaction(transaction: transaction)
                    completion(NetworkError.badResponse(code: nil))
                }
            }
        }
        
        task.resume()
        
    }
    
    
    public func deleteParty(thePartyID ID: String, completion: @escaping(_ error: NetworkError?) -> Void) {
        
        let transaction = Transaction(withDate: Date())
        
        //        guard Configuration.internetStatus != .notReachable else{
        //            transaction.addErrorDescription(theError: NetworkError.noInternet)
        //            TransactionController.shared.addNewTransaction(transaction: transaction)
        //            completion(NetworkError.noInternet)
        //            return
        //        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party").appendingPathComponent(ID) else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        print(finalURL)
        
        var request = URLRequest(url: finalURL)
        
        request.httpMethod = HTTPMethod.DELETE.rawValue
        request.setValue(contentTypeValue, forHTTPHeaderField: contentTypeHeader)

        
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
                    
                    if let message = JSON["message"] as? String {
                        print(message)
                    }
                    
                    self.mainQueue.async {
                        TransactionController.shared.addNewTransaction(transaction: transaction)
                        completion(nil)
                    }
                    
                default:
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.badResponse(code: httpResponse.statusCode))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.badResponse(code: httpResponse.statusCode))
                        }
                    }
                    
                }else{
                    self.mainQueue.async {
                        transaction.addErrorDescription(theError: NetworkError.badResponse(code: nil))
                        TransactionController.shared.addNewTransaction(transaction: transaction)
                        completion(NetworkError.badResponse(code: nil))
                    }
                }
            }
            
            task.resume()

    }
    
    
    
}

