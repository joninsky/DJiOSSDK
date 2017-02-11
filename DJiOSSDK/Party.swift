//
//  Party.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift

public class Party: Object {
    
    public internal(set) dynamic var id: String?
    
    dynamic var dj: User?
    
    public internal(set) var participants = List<User>()
    
    dynamic public internal(set) var name: String?
    
    public internal(set) dynamic var location: Location?
    
    public internal(set) dynamic var publicParty = false
    
    dynamic var created_at: Date?
    
    dynamic var updated_at: Date?
    
    public internal(set) var votes = List<Vote>()
    
    public convenience init?(withDictionary d: [String: Any]) {
        self.init()
        
        guard let _ = d[PartyJSON.name.rawValue] as? String else {
            return nil
        }
        
        guard let _ = d[PartyJSON.location.rawValue] as? [String: Any] else {
            return nil
        }
        
        do{
            try self.crackJSON(theJSON: d)
        }catch{
            
        }
    }
    
    
    func getJSON() -> [String: Any] {
        var object: [String: Any] = [PartyJSON.name.rawValue: self.name,
                      PartyJSON.dj.rawValue: self.dj?.id,
                      PartyJSON.participants.rawValue: self.getParticipants(),
                      PartyJSON.location.rawValue: self.location?.getJSON(),
                      PartyJSON.publicParty.rawValue: self.publicParty]
        
        if let id = self.id {
            object[PartyJSON.id.rawValue] = id
        }
        
        return object
    }
    
    
    func getParticipants() -> [String] {
        var array = [String]()
        for p in self.participants {
            guard let id = p.id else{
                break
            }
            array.append(id)
        }
        return array
    }
    
    public func countVoteType(_ type: VoteType) -> Int {
        let validVotes =  self.votes.filter("rawVoteType = %@", type.rawValue)
        
        var uniqueVotes = Set<String>()
        
        
        for vote in validVotes {
            guard let ID = vote.voterID else{
                break
            }
            
            if !uniqueVotes.contains(ID) {
                uniqueVotes.insert(ID)
            }
        }
        
        return uniqueVotes.count
        
    }
    
    
    func delete() throws {
        if let realm = self.realm {
            do{
                try realm.write {
                    if let loc = self.location {
                        realm.delete(loc)
                    }
                    realm.delete(self.votes)
                    realm.delete(self)
                }
            }catch{
                throw error
            }
        }
    }
    
    internal func crackJSON(theJSON JSON: [String: Any]) throws {
        if let id = JSON[PartyJSON.id.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write{
                        self.id = id
                    }
                }catch{
                    throw error
                }
            }else{
                self.id = id
            }
        }
        
        if let name = JSON[PartyJSON.name.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write{
                        self.name = name
                    }
                }catch{
                    throw error
                }
            }else{
                self.name = name
            }
        }
        
        if let dj = JSON[PartyJSON.dj.rawValue] as? String {
            if let realm = self.realm {
                do{
                    try realm.write{
                        self.dj = realm.objects(User.self).filter("id = %@", dj).first
                    }
                }catch{
                    throw error
                }
            }else{
                self.dj = Configuration.defaultConfiguration?.DJRealm.objects(User.self).filter("id = %@", dj).first
            }
        }
        
        if let participants = JSON[PartyJSON.participants.rawValue] as? [String] {
            
            for u in participants {
                guard let user = self.realm?.objects(User.self).filter("id = %@", u).first else{
                    break
                }
                
                if let realm = self.realm {
                    do{
                        try realm.write{
                            self.participants.append(user)
                        }
                    }catch{
                        throw error
                    }
                }else{
                    self.participants.append(user)
                }
            }
            
            
        }
        
        if let locationData = JSON[PartyJSON.location.rawValue] as? [String: Any], let coordinates = locationData["coordinates"] as? [Double], let long = coordinates.first, let lat = coordinates.last {
            
            let location = Location()
            
            do{
                try location.addLocation(long: long, lat: lat)
            }catch{
                throw error
            }
            
            if let realm = self.realm {
                do{
                    try realm.write{
                        self.location = location
                    }
                }catch{
                    throw error
                }
            }else{
                self.location = location
            }
        }
        
        if let publicParty = JSON[PartyJSON.publicParty.rawValue] as? NSNumber {
            if let realm = self.realm {
                do{
                    try realm.write{
                        self.publicParty = Bool(publicParty)
                    }
                }catch{
                    throw error
                }
            }else{
                self.publicParty = Bool(publicParty)
            }
        }
        
        if let created = JSON[PartyJSON.created_at.rawValue] as? Date {
            if let realm = self.realm {
                do{
                    try realm.write{
                        self.created_at = created
                    }
                }catch{
                    throw error
                }
            }else{
                self.created_at = created
            }
        }
        
        if let updated = JSON[PartyJSON.updated_at.rawValue] as? Date {
            if let realm = self.realm {
                do{
                    try realm.write{
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
    

    
    
    public func updateLocation(_ loc: Location, completion: @escaping (_ error: NetworkError?) -> Void) {
        var updates = [PartyJSON.location.rawValue: loc.getJSON()]
        
        let manager = PartyNetworkManager()
        
        manager.updateParty(theParty: self, updates: updates) { (error) in
            completion(error)
        }
    }
    
    public func updateName(_ n: String, completion: @escaping ( _ error: NetworkError?) -> Void)  {
        var updates = [PartyJSON.name.rawValue: n]
        
        let manager = PartyNetworkManager()
        
        manager.updateParty(theParty: self, updates: updates) { (error) in
            completion(error)
        }
    }
    
    
    public func setPublic(isPublic p: Bool, completion: @escaping ( _ error: NetworkError?) -> Void) {
        
        var updates = [PartyJSON.publicParty.rawValue: p]
        
        let manager = PartyNetworkManager()
        
        manager.updateParty(theParty: self, updates: updates) { (error) in
            completion(error)
        }
    }
    
    
    public func addVote(theVote V: Vote) throws {
        
        if let realm = self.realm {
            do{
                try realm.write {
                    self.votes.append(V)
                }
            }catch{
                throw error
            }
        }else{
            self.votes.append(V)
        }
        
        NotificationCenter.default.post(name: VoteNotification, object: V)
    }
    
    
    public func invalidateCurrentVotes() {
        for v in self.votes {
            v.invalidte()
        }
    }
    
}

