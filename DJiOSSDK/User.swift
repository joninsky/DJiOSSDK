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
    dynamic internal var spotifyRefreshToken: String?
    dynamic internal var spotifyToken: String?
    dynamic internal var spotifyTokenExpiration: Date?
    dynamic public internal(set) var spotify_login = false
    dynamic public internal(set) var djScore: Double = 0.9
    dynamic internal var pushToken: String?
    dynamic internal var pushSandbox: Bool = false
    
    internal var potentialParties = LinkingObjects(fromType: Party.self, property: "dj")
    
    public var myParty: Party? {
        return self.potentialParties.first
    }
    let participatingPartys = LinkingObjects(fromType: Party.self, property: "participants")
    public var participatingParty: Party? {
        return self.participatingPartys.first
    }
    dynamic public internal(set) var created_at: Date?
    dynamic public internal(set) var updated_at: Date?
    dynamic public internal(set) var loggedIn = false
    
    public internal(set) dynamic var invitation: Party?
    
    public convenience init?(withDictionary d: [String: Any]) {
        self.init()
        
        do{
            try self.crackJSON(theJSON: d)
        }catch{
            return nil
        }
    }
    
    internal func getJSON() -> [String: Any] {
        var object: [String: Any] = [UserJSON.name.rawValue: self.name,
                      UserJSON.djName.rawValue: self.djName,
                      UserJSON.email.rawValue: self.email,
                      UserJSON.facebook_id.rawValue: self.facebookID,
                      UserJSON.facebook_login.rawValue: self.facebook_login,
                      UserJSON.facebookToken.rawValue: self.facebookToken,
                      UserJSON.spotifyRefreshToken.rawValue: self.spotifyRefreshToken,
                      UserJSON.spotifyToken.rawValue: self.spotifyToken,
                      UserJSON.spotifyTokenExpiration.rawValue: self.spotifyTokenExpiration,
                      UserJSON.spotify_login.rawValue: self.spotify_login,
                      UserJSON.djscore.rawValue: self.djScore,
                      UserJSON.pushToken.rawValue: self.pushToken,
                      UserJSON.pushSandbox.rawValue: self.pushSandbox]
        
        return object
    }
    
    internal func crackJSON(theJSON JSON: [String: Any]) throws {
        
        if let id = JSON[UserJSON.id.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.id = id
                        self.id_string = id
                    }
                }catch{
                    throw error
                }
            }else{
                self.id = id
                self.id_string = id
            }
        }
        
        if let name = JSON[UserJSON.name.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.name = name
                    }
                }catch{
                    throw error
                }
            }else{
                self.name = name
            }
        }
        
        if let djName = JSON[UserJSON.djName.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.djName = djName
                    }
                }catch{
                    throw error
                }
            }else{
                self.djName = djName
            }
        }
        
        if let email = JSON[UserJSON.email.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                         self.email = email
                    }
                }catch{
                    throw error
                }
            }else{
                self.email = email
            }
        }
    
        if let faceBookLogin = JSON[UserJSON.facebook_login.rawValue] as? NSNumber {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.facebook_login = Bool(faceBookLogin)
                    }
                }catch{
                    throw error
                }
            }else{
                self.facebook_login = Bool(faceBookLogin)
            }
        }
        
        if let faceBookID = JSON[UserJSON.facebook_id.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.facebookID = faceBookID
                    }
                }catch{
                    throw error
                }
            }else{
                self.facebookID = faceBookID
            }
        }
        
        if let faceBookToken = JSON[UserJSON.facebookToken.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.facebookToken = faceBookToken
                    }
                }catch{
                    throw error
                }
            }else{
                self.facebookToken = faceBookToken
            }
        }
        
        if let theSpotifyToken = JSON[UserJSON.spotifyToken.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.spotifyToken = theSpotifyToken
                    }
                }catch{
                    throw error
                }
            }else{
                self.spotifyToken = theSpotifyToken
            }
        }
        
        if let spotifyLogin = JSON[UserJSON.spotify_login.rawValue] as? NSNumber {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.spotify_login = Bool(spotifyLogin)
                    }
                }catch{
                    throw error
                }
            }else{
                self.spotify_login = Bool(spotifyLogin)
            }
        }
        
        if let score = JSON[UserJSON.djscore.rawValue] as? Double {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.djScore = score
                    }
                }catch{
                    throw error
                }
            }else{
                self.djScore = score
            }
        }
        
        if let pushToken = JSON[UserJSON.pushToken.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.pushToken = pushToken
                    }
                }catch{
                    throw error
                }
            }else{
                self.pushToken = pushToken
            }
        }
        
        if let sandBoxToken = JSON[UserJSON.pushSandbox.rawValue] as? NSNumber {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.pushSandbox = Bool(sandBoxToken)
                    }
                }catch{
                    throw error
                }
            }else{
                self.pushSandbox = Bool(sandBoxToken)
            }
        }
        
        if let myParty = JSON[UserJSON.myParty.rawValue] as? String {
           
            if self.myParty?.id != myParty {
                if let party = self.realm?.objects(Party.self).filter("id = %@", myParty).first {
                    if let realm = self.realm {
                        do{
                            try realm.write {
                                party.dj = self
                            }
                        }catch{
                            throw error
                        }
                    }else{
                        party.dj = self
                    }
                }else{
                    let manager = PartyNetworkManager()
                    manager.getParty(withID: myParty, completion: { (error, party) in
                        if let p = party {
                            if p.realm == nil {
                                do{
                                    try Configuration.defaultConfiguration?.DJRealm.write {
                                        Configuration.defaultConfiguration?.DJRealm.add(p)
                                    }
                                }catch{
                                    
                                }
                            }
                        }
                    })
                }
            }
            
            
        }
        
        if let participatingParty = JSON[UserJSON.participatingParty.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        
                    }
                }catch{
                    throw error
                }
            }else{
                
            }
        }
        
        if let created = JSON[UserJSON.created_at.rawValue] as? Date {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.created_at = created
                    }
                }catch{
                    throw error
                }
            }else{
                self.created_at = created
            }
        }
        
        if let updated = JSON[UserJSON.updated_at.rawValue] as? Date {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.updated_at = updated
                    }
                }catch{
                    throw error
                }
            }else{
                self.updated_at = updated
            }
        }
        
    }
    
    //MARK: Property Setters
    public func updateName( _ n: String, completion: @escaping (_ error: NetworkError?) -> Void) {
        
        guard self.name != n else {
            completion(nil)
            return
        }
        
        let controller = LoginNetworkManager()
        
        controller.updateUser(theUser: self, updates: [UserJSON.name.rawValue: n]) { (error) in
            if let e = error {
                completion(e)
            }else{
                do{
                    try self.crackJSON(theJSON: [UserJSON.name.rawValue: n])
                    completion(nil)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
            }
        }
    }
    
    public func updateEmail( _ e: String, completion: @escaping (_ error: NetworkError?) -> Void) {
        guard self.email != e else {
            completion(nil)
            return
        }
        
        let update = [UserJSON.email.rawValue: e]
        
        let controller = LoginNetworkManager()
        
        controller.updateUser(theUser: self, updates: update) { (error) in
            if let e = error {
                completion(e)
            }else{
                do{
                    try self.crackJSON(theJSON: update)
                    completion(nil)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
            }
        }
    }
    
    public func updateDJName( _ djName: String, completion: @escaping (_ error: NetworkError?) -> Void) {
        guard self.djName != djName else {
            completion(nil)
            return
        }
        
        let update = [UserJSON.djName.rawValue: djName]
        
        let controller = LoginNetworkManager()
        
        controller.updateUser(theUser: self, updates: update) { (error) in
            if let e = error {
                completion(e)
            }else{
                do{
                    try self.crackJSON(theJSON: update)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
            }
        }
        
    }
    
    public func updatePushNotificationToken( _ token: String, sandBox: Bool, completion: @escaping ( _ error: NetworkError?) -> Void) {
        
        
        var updates = [String: Any]()
        
        updates = [UserJSON.pushToken.rawValue: token]
        
        updates[UserJSON.pushSandbox.rawValue] = sandBox
        
        let controller = LoginNetworkManager()
        
        controller.updateUser(theUser: self, updates: updates) { (error) in
            
            if let e = error {
                completion(e)
            }else{
                do{
                    try self.crackJSON(theJSON: updates)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
            }
        }
    }
    
    
    public func addInvitation( invitedparty party: Party) throws {
        if let realm = self.realm {
            do{
                try realm.write {
                    self.invitation = party
                }
            }catch{
                throw error
            }
        }else{
            self.invitation = party
        }
    }
    
    public func accepetInvitation(completion: @escaping (_ error: NetworkError?) -> Void) {
        guard let party = self.invitation else {
            completion(NetworkError.realmError(e: nil))
            return
        }
        
        self.joinParty(theParty: party) { (error) in
            if let e = error {
                completion(e)
            }else{
                do{
                    try self.declineInvitation()
                    completion(nil)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
            }
        }
    }
    
    
    public func declineInvitation() throws {
        if let realm = self.realm {
            do{
                try realm.write {
                    self.invitation = nil
                }
            }catch{
                throw error
            }
        }else{
            self.invitation = nil
        }
    }
    
    
    
    public func startParty(theParty p: Party, completion: @escaping (_ error: NetworkError?) -> Void) {
        let partyController = PartyNetworkManager()
        partyController.createParty(party: p, byUser: self) { (error) in
            if let e = error {
                completion(e)
            }else{
                do{
                    try Configuration.defaultConfiguration?.DJRealm.write {
                        Configuration.defaultConfiguration?.DJRealm.add(p)
                    }
                    completion(nil)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
                
            }
        }
        
    }
    
    
    public func endParty(completion: @escaping (_ error: NetworkError?) -> Void) {
        
        guard let party = self.myParty else{
            completion(NetworkError.realmError(e: nil))
            return
        }

        let net = PartyNetworkManager()
        
        net.deleteParty(theParty: party) { (error) in
            if let e = error {
                completion(e)
            }else{
                completion(nil)
            }
        }
        
    }
    
    public func joinParty(theParty p: Party, completion: @escaping ( _ error: NetworkError?) -> Void) {
        
        guard let id = self.id else {
            completion(NetworkError.realmError(e: nil))
            return
        }
        
        var participants = p.getParticipants()
        
        if !participants.contains(id) {
            participants.append(id)
        }
        
        let updates = [PartyJSON.participants.rawValue: participants]
        
        let manager = PartyNetworkManager()
        
        manager.updateParty(theParty: p, updates: updates) { (error) in
            if let e = error{
                completion(e)
            }else{
                
                guard let realm = Configuration.defaultConfiguration?.DJRealm else {
                    completion(NetworkError.realmError(e: nil))
                    return
                }
                
                do{
                    try realm.write {
                        realm.add(p)
                    }
                    try p.crackJSON(theJSON: updates)
                    try self.crackJSON(theJSON: [UserJSON.participatingParty.rawValue: id])
                    completion(nil)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
                
            }
        }
    }
    
    public func leaveParty(completion: @escaping (_ error: NetworkError?) -> Void) {

        guard let party = self.participatingParty, let ID = party.id, let userID = self.id else {
            completion(NetworkError.realmError(e: nil))
            return
        }
        
        var participants = party.getParticipants()
        
        if let index = participants.index(of: userID) {
            participants.remove(at: index)
        }
        
        let updates = [PartyJSON.participants.rawValue: participants]
        
        let manager = PartyNetworkManager()
        
        manager.updateParty(theParty: party, updates: updates) { (error) in
            if let e = error {
                switch e {
                case .badResponse(code: let code):
                    if code == 405 {
                        do{
                            try self.participatingParty?.delete()
                            completion(nil)
                        }catch{
                            completion(NetworkError.realmError(e: error))
                        }
                    }
                default:
                     completion(e)
                }
                completion(e)
            }else{
                do{
                    try self.participatingParty?.delete()
                    completion(nil)
                }catch{
                    completion(NetworkError.realmError(e: error))
                }
            }
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

