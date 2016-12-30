//
//  PartyNetworkManager.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

class PartyNetworkManager {
    
    //MARK: Properties
    
    let session = URLSession.shared
    let mainQueue = DispatchQueue.main
    
    let urlString = "http://192.168.1.58:3000/api"
    //let urlString = "http://172.31.99.143:3000/api"
    //let urlString = "http://localhost:3000/api"
    
    //MARK: Initalier
    init?(){
        
        
        
    }
    
    
    
    func createParty(party p: Party, byUser u: User, completion: @escaping(_ error: NetworkError?) -> Void) {
        
        guard let finalURL = URL(string: self.urlString)?.appendingPathComponent("party") else{
            completion(NetworkError.badURL)
            return
        }
        
        var request = URLRequest(url: finalURL)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            var JSON = p.getJSON()
            JSON[PartyJSON.dj.rawValue] = u.id
            request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
        }catch{
            completion(NetworkError.couldNotSetPOSTBody(e: error))
            return
        }
        
        let task = self.session.dataTask(with: request) { (data, response, error) in
            if let e = error{
                self.mainQueue.async {
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
                            completion(NetworkError.failedToParseJSON)
                        }
                    }
                    
                    print(JSON)
                    
                    if let message = JSON["message"] as? String {
                        print(message)
                    }
                    
                    guard let id = JSON["id"] as? String else {
                        self.mainQueue.async {
                            completion(NetworkError.failedToParseJSON)
                        }
                        return
                    }
                    
                    self.mainQueue.async {
                        do{
                            try p.bindID(id)
                            self.mainQueue.async {
                                completion(nil)
                            }
                        }catch{
                            self.mainQueue.async {
                                completion(NetworkError.realmError(e: error))
                            }
                        }
                    }
                    
                default:
                    self.mainQueue.async {
                        completion(NetworkError.badResponse(code: httpResponse.statusCode))
                    }
                }
                
            }else{
                self.mainQueue.async {
                    completion(NetworkError.badResponse(code: nil))
                }
            }
        }
        
        task.resume()
        
    }
    
    
    
}

