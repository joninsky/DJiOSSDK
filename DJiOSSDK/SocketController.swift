//
//  SocketController.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/30/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation
import SocketIO



public class SocketController: Networker  {
    //MARK: Properties
    var socket: SocketIOClient?
    
    
    public override init() {
        super.init()
        if let url = URL(string: self.urlString)?.deletingLastPathComponent() {
            self.socket = SocketIOClient(socketURL: url)
        }else{
            
        }
    }
    
    
    //MARK: Connect and Disconnect functions
    public func establishConnection(){
        self.socket?.connect()
    }
    
    
    public func leaveConnection(){
        self.socket?.disconnect()
    }
    
    
    public func getPeople(forName n: String, callback: @escaping (_ theParties: [User]?) -> Void) {
        
        self.socket?.emit("getPeople", n)
        
        self.socket?.on("postPeople", callback: { (data, ack) in
            guard let ROOT = data.first as? [Any] else{
                callback(nil)
                return
            }
            
            var users = [User]()
            
            for item in ROOT {
                guard let INFO = item as? [String: Any] else {
                    break
                }
                
                guard let pulledUser = User(withDictionary: INFO) else{
                    break
                }
                
                
                users.append(pulledUser)
                
            }
            
            callback(users)
            
        })
    }
    
    public func joinParty(partyID ID: String, completion: @escaping(_ didJoin: Bool) -> Void){
        
        self.socket?.emit("joinParty", ID)
        
        self.socket?.on("joinPartyResults", callback: { (data, ack) in
            
            guard data.count != 0 else {
                completion(false)
                return
            }
            
            guard let number = data[0] as? NSNumber else{
                completion(false)
                return
            }
            
            print(number)
            completion(Bool(number))
        })
        
        
    }
    
    
    public func getParties(distance: Double, nearlongitude: Double, andLatitude: Double, callback: @escaping (_ theParties: [Party]?) -> Void) {
        
    
        
        let point = [distance, nearlongitude, andLatitude]
        
        self.socket?.emit("getLocationParties", point)
        
        self.socket?.on("postPartiesByLocation", callback: { (data, ack) in
            guard let ROOT = data.first as? [Any] else{
                callback(nil)
                return
            }
            
            var parties = [Party]()
            
            for item in ROOT {
                
                guard let INFO = item as? [String: Any] else{
                    break
                }
                
                guard let object = INFO["obj"] as? [String: Any] else {
                    return
                }
                
                guard let pulledParty = Party(withDictionary: object) else{
                    break
                }
                
                parties.append(pulledParty)
                
            }
            
            callback(parties)
            
        })
        
        
    }
    
    public func getParties(forName n: String, callback: @escaping (_ theParties: [Party]?) -> Void) {
        
        self.socket?.emit("getParties", n)
        
        self.socket?.on("postParties", callback: { (data, ack) in
            
            
            guard let ROOT = data.first as? [Any] else{
                callback(nil)
                return
            }
            var parties = [Party]()
            
            for item in ROOT {

                guard let INFO = item as? [String: Any] else{
                    break
                }
                
                guard let pulledParty = Party(withDictionary: INFO) else{
                    break
                }
                
                parties.append(pulledParty)
                
            }
            
            callback(parties)
            
        })
        
    }
    
}
