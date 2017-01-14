//
//  User.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift

public class User: Object {
    
    
    dynamic internal var id: String?
    dynamic internal var id_string: String?
    dynamic public internal(set) var name: String?
    dynamic public internal(set)var djName: String?
    dynamic public internal(set)var email: String?
    dynamic public internal(set) var facebook_login = false
    dynamic public internal(set) var facebookID: String?
    dynamic internal var facebookToken: String?
    dynamic public internal(set) var spotify_login = false
    dynamic public internal(set) var djScore: Double = 0
    dynamic internal var pushToken: String?
    dynamic internal var pushSandbox: String?
    dynamic public internal(set) var myParty: Party?
    dynamic public internal(set) var currentParty: Party?
    dynamic public internal(set) var created_at: Date?
    dynamic public internal(set) var updated_at: Date?
    dynamic public internal(set) var loggedIn = false
    
    public convenience init?(withFaceBookID fID: String, faceBookToken t: String, andEmail e: String) {
        self.init()
        if let r = self.realm {
            do{
                try r.write{
                    self.facebookID = fID
                    self.facebookToken = t
                    self.facebook_login = true
                    self.email = e
                    self.djScore = 2.0
                }
            }catch{
                return nil
            }
        }else{
            self.facebookID = fID
            self.facebookToken = t
            self.facebook_login = true
            self.email = e
            self.djScore = 2.0
        }
    }
    
    public convenience init?(withDictionary d: [String: Any]) {
        self.init()
        if let name = d[UserJSON.name.rawValue] as? String {
            self.name = name
        }
        
        if let djName = d[UserJSON.djName.rawValue] as? String {
            self.djName = djName
        }
        
        if let facebook = d[UserJSON.facebook_id.rawValue] as? String {
            self.facebookID = facebook
        }
        
    }
    
    internal func getJSON() -> [String: Any] {
        return [UserJSON.name.rawValue: self.name,
                UserJSON.djName.rawValue: self.djName,
                UserJSON.email.rawValue: self.email,
                UserJSON.facebook_id.rawValue: self.facebookID,
                UserJSON.facebook_login.rawValue: self.facebook_login,
                UserJSON.facebookToken.rawValue: self.facebookToken,
                UserJSON.spotify_login.rawValue: self.spotify_login,
                UserJSON.djscore.rawValue: self.djScore,
                UserJSON.pushToken.rawValue: self.pushToken,
                UserJSON.pushSandbox.rawValue: self.pushSandbox]
    }
    
    //MARK: Property Setters
    public func updateName( _ n: String) throws {
        guard self.name != n else{
            return
        }
        
        if let r = self.realm {
            do{
                try r.write {
                    self.name = n
                }
            }catch{
                
            }
        }else{
            self.name = n
        }
        
    }
    
    public func updateEmail( _ e: String) throws {
        
    }
    
    public func updateDJName( _ djName: String) throws {
        
        
    }
    
    
    
    public func startParty(theParty p: Party, completion: @escaping (_ error: NetworkError?) -> Void) {
        let partyController = PartyNetworkManager()
        partyController.createParty(party: p, byUser: self) { (error) in
            if let e = error {
                completion(e)
            }else{
                if let r = self.realm {
                    do{
                        try r.write {
                            self.myParty = p
                        }
                    }catch{
                        completion(NetworkError.realmError(e: error))
                        return
                    }
                }else{
                    self.myParty = p
                }
                completion(nil)
            }
            
            
        }
        
    }
    
    
    public func endParty(completion: @escaping (_ error: NetworkError?) -> Void) {
        
        guard let party = self.myParty, let id = party.id else{
            completion(NetworkError.realmError(e: nil))
            return
        }

        let net = PartyNetworkManager()
        
        net.deleteParty(thePartyID: id) { (error) in
            if let e = error {
                completion(e)
            }else{
                if let r = self.realm {
                    do{
                        try r.write {
                            r.delete(party)
                        }
                        
                    }catch{
                        completion(NetworkError.realmError(e: error))
                        return
                    }
                }else{
                    self.myParty = nil
                }
                
                completion(nil)
            }
        }
        
    }
    
    public func joinParty(theParty p: Party) throws {
        if let r = self.realm {
            do{
                try r.write {
                    self.currentParty = p
                }
            }catch{
                throw error
            }
        }else{
            self.currentParty = p
        }
    }
    
    public func leaveParty() throws {
        if let r = self.realm{
            do{
                try r.write {
                    self.currentParty = nil
                }
            }catch{
                
            }
        }else{
            self.currentParty = nil
        }
    }
    
    
}


extension User {
    static public func loggedInUser() -> User? {
        guard let realm = Configuration.defaultConfiguration?.DJRealm else {
            return nil
        }
        let users = realm.objects(User.self).filter("loggedIn == TRUE")
        
        if users.count > 1 {
            return nil
        }else if let user = users.first {
            
            return user
        }else{
            return nil
        }
    }
    
    
    static public func logInUser(user u: User) throws {
        guard let realm = Configuration.defaultConfiguration?.DJRealm else{
            throw LogInError.noRealm
        }
        
        u.loggedIn = true
        
        do{
            try realm.write {
                realm.add(u)
                
            }
        }catch{
            throw LogInError.realmError(e: error)
        }
        
        
    }
    
    static public func logOut() throws {
        guard  let realm = Configuration.defaultConfiguration?.DJRealm else {
            throw LogOutError.noRealm
        }
        
        do{
            try realm.write {
                realm.delete(realm.objects(User.self))
                realm.delete(realm.objects(Party.self))
            }
        }catch{
            throw LogOutError.realmError(e: error)
        }
        
        
    }
    
}

