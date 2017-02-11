//
//  PartyNetworkManager.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

public class PartyNetworkManager: Networker {
    
    
    func createParty(party p: Party, byUser u: User, completion: @escaping(_ error: NetworkError?) -> Void) {
        
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
    
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party") else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.POST)
        
        do{
            var JSON = p.getJSON()
            JSON[PartyJSON.dj.rawValue] = u.id
            let data = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
            request.httpBody = data
        }catch{
            transaction.addErrorDescription(theError: NetworkError.couldNotSetPOSTBody(e: error))
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }
        
        transaction.addRequest(request: request)
        
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
                    
                    
                   // print(JSON)
                    
                    guard let party = JSON["party"] as? [String: Any] else {
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(nil))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(nil))
                        }
                        return
                    }
                    
                    self.mainQueue.async {
                        do{
                            try p.crackJSON(theJSON: party)
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
    
    
    public func deleteParty(theParty party: Party, completion: @escaping(_ error: NetworkError?) -> Void) {
        
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
        
        guard let ID = party.id else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party").appendingPathComponent(ID) else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.DELETE)

        
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
                        do{
                            try party.delete()
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
    
    func updateParty(theParty party: Party, updates: [String: Any], completion: @escaping ( _ error: NetworkError?) -> Void) {

        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
        
        guard let ID = party.id else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party").appendingPathComponent(ID) else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.PUT)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: updates, options: .prettyPrinted)
        }catch{
            transaction.addErrorDescription(theError: NetworkError.couldNotSetPOSTBody(e: error))
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }
        
        transaction.addRequest(request: request)
        
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
                    
                    
                    guard let newData = JSON["party"] as? [String: Any] else {
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(nil))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(nil))
                        }
                        return
                    }
                    
                    self.mainQueue.async {
                        do{
                            try party.crackJSON(theJSON: newData)
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
    
    func getParty(withID ID: String, completion: @escaping (_ error: NetworkError?, _ party: Party?) -> Void){
        
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet, nil)
            return
        }
        
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party").appendingPathComponent(ID) else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL, nil)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.GET)
        
        transaction.addRequest(request: request)
        
        let task = self.session.dataTask(with: request) { (data, response, error) in
            
            transaction.addSessionResponse(date: data, response: response, error: error)
            
            if let e = error{
                self.mainQueue.async {
                    transaction.addErrorDescription(theError: NetworkError.requestError(e: e))
                    TransactionController.shared.addNewTransaction(transaction: transaction)
                    completion(NetworkError.requestError(e: e), nil)
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
                            completion(NetworkError.failedToParseJSON(error), nil)
                        }
                    }
                    
                    guard let partyInfo = JSON["party"] as? [String: Any] else {
                        self.mainQueue.async {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(nil))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(nil), nil)
                        }
                        return
                    }
                    

                    
                    self.mainQueue.async {
                        guard let newParty = Party(withDictionary: partyInfo) else {
                            transaction.addErrorDescription(theError: NetworkError.failedToParseJSON(nil))
                            TransactionController.shared.addNewTransaction(transaction: transaction)
                            completion(NetworkError.failedToParseJSON(nil), nil)
                            return
                        }
                        completion(nil, newParty)
                    }
                    
                    
                    
                default:
                    self.mainQueue.async {
                        transaction.addErrorDescription(theError: NetworkError.badResponse(code: httpResponse.statusCode))
                        TransactionController.shared.addNewTransaction(transaction: transaction)
                        completion(NetworkError.badResponse(code: httpResponse.statusCode), nil)
                    }
                }
                
            }else{
                self.mainQueue.async {
                    transaction.addErrorDescription(theError: NetworkError.badResponse(code: nil))
                    TransactionController.shared.addNewTransaction(transaction: transaction)
                    completion(NetworkError.badResponse(code: nil), nil)
                }
            }
        }
        
        task.resume()
        
    }
    
    public func invite(aUser user: User, toParty party: Party, completion: @escaping ( _ error: NetworkError?) -> Void ) {
        
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
        
        guard let ID = user.id else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party").appendingPathComponent("invite").appendingPathComponent(ID) else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.POST)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: party.getJSON(), options: .prettyPrinted)
        }catch{
            transaction.addErrorDescription(theError: NetworkError.couldNotSetPOSTBody(e: error))
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }
        
        transaction.addRequest(request: request)
        
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
                    
                    
                    self.mainQueue.sync {
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
    
    
    public func vote(typeOfVote vote: VoteType, user U: User, completion: @escaping (_ error: NetworkError?) -> Void) {
        
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
        
        guard let ID = U.participatingParty?.id else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party").appendingPathComponent("vote").appendingPathComponent(ID) else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.POST)
        
        let keys = VoteJSON()
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: ["vote": vote.rawValue, keys.userName: U.name, keys.voterID: U.id], options: .prettyPrinted)
        }catch{
            transaction.addErrorDescription(theError: NetworkError.couldNotSetPOSTBody(e: error))
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }
        
        transaction.addRequest(request: request)
        
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
                    
                    
                    self.mainQueue.sync {
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
    
    
    public func broadcast(newSong song: String, forParty P: Party, completion: @escaping (_ sender: NetworkError?) -> Void) {
        let transaction = Transaction(withDate: Date())
        
        guard Networker.internetStatus != .notReachable else{
            transaction.addErrorDescription(theError: NetworkError.noInternet)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.noInternet)
            return
        }
        
        guard let ID = P.id else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party").appendingPathComponent("newSong").appendingPathComponent(ID) else{
            transaction.addErrorDescription(theError: NetworkError.badURL)
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.badURL)
            return
        }
        
        var request = self.getRequest(withURL: finalURL, forMethodType: HTTPMethod.POST)
        
        let keys = VoteJSON()
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: ["song": song], options: .prettyPrinted)
        }catch{
            transaction.addErrorDescription(theError: NetworkError.couldNotSetPOSTBody(e: error))
            TransactionController.shared.addNewTransaction(transaction: transaction)
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }
        
        transaction.addRequest(request: request)
        
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
                    
                    
                    self.mainQueue.sync {
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

