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
    dynamic internal var facebookID: String?
    dynamic internal var facebookToken: String?
    dynamic public internal(set) var spotify_login = false
    dynamic public internal(set) var djScore: Double = 0
    dynamic internal var pushToken: String?
    dynamic internal var pushSandbox: String?
    public internal(set) var usersParties: List<Party> = List<Party>()
    public internal(set) var currentParty: Party?
    dynamic public internal(set) var created_at: Date?
    dynamic public internal(set) var updated_at: Date?
    dynamic public internal(set) var loggedIn = false
    
    
    internal func getJSON() -> [String: Any] {
        return [UserJSON.name.rawValue: self.name, UserJSON.djName.rawValue: self.djName, UserJSON.email.rawValue: self.email, UserJSON.facebook_id.rawValue: self.facebookID, UserJSON.facebook_login.rawValue: self.facebook_login, UserJSON.facebookToken.rawValue: self.facebookToken, UserJSON.spotify_login.rawValue: self.spotify_login, UserJSON.djscore.rawValue: self.djScore, UserJSON.pushToken.rawValue: self.pushToken, UserJSON.pushSandbox.rawValue: self.pushSandbox]
    }
    
    public func addParty(theParty p: Party) throws {
        if let r = self.realm {
            do{
                try r.write {
                    self.usersParties.append(p)
                }
            }catch{
                throw error
            }
        }else{
            self.usersParties.append(p)
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

