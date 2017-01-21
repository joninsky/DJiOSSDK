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
    
    let participants = List<User>()
    
    dynamic public internal(set) var name: String?
    
    public var location: Location?
    
    public internal(set) dynamic var publicParty = false
    
    dynamic var created_at: Date?
    
    dynamic var updated_at: Date?
    
    public convenience init?(withDictionary d: [String: Any]) {
        self.init()
        print(d)
        
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
        return [PartyJSON.id.rawValue: self.id,
                PartyJSON.name.rawValue: self.name,
                PartyJSON.dj.rawValue: self.dj?.id,
                PartyJSON.participants.rawValue: self.getParticipants(),
                PartyJSON.location.rawValue: self.location?.getJSON(),
                PartyJSON.publicParty.rawValue: self.publicParty]
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
    
    
    func delete() throws {
        if let realm = self.realm {
            do{
                try realm.write {
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
            if let realm = self.realm {
                do{
                    try realm.write{
                        
                    }
                }catch{
                    throw error
                }
            }else{
                
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
    

    
    
    public func updateLocation(_ loc: Location) {
        if self.realm == nil {
            self.location = loc
        }else if let l = self.location{
            do{
                try self.realm?.write {
                    self.realm?.delete(l)
                    self.location = loc
                }
            }catch{
                
            }
        }else{
            do{
                try self.realm?.write {
                    self.location = loc
                }
            }catch{
                
            }
            
        }
    }
    
    public func updateName(_ n: String) throws {
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
    
    
    public func setPublic(isPublic p: Bool) throws {
        guard self.publicParty != p else{
            return
        }
        
        if let realm = self.realm {
            do{
                try realm.write{
                    self.publicParty = p
                }
            }catch{
                throw error
            }
        }else{
            self.publicParty = p
        }
    }
    
}

