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
    
    dynamic var djID: String?
    
    dynamic public internal(set) var name: String?
    
    public var location: Location?
    
    public internal(set) dynamic var publicParty = false
    
    dynamic var created_at: Date?
    
    dynamic var updated_at: Date?
    
    public convenience init?(withDictionary d: [String: Any]) {
        
        self.init()
        
        guard self.realm == nil else{
            return
        }
        
        if let name = d["partyName"] as? String {
            self.name = name
        }
        
        if let location = d["location"] as? [String: Any] {
            if let coordinates = location["coordinates"] as? [Double] {
                if let long = coordinates.first, let lat = coordinates.last {
                    let partiesLocation = Location()
                    
                    do{
                        try partiesLocation.addLocation(long: long, lat: lat)
                    }catch{
                        
                    }
                    
                    
                    self.location = partiesLocation
                }
            }
        }
        
        if let _id = d["_id"] as? String {
            self.id = _id
        }
        
        if let _dj = d["dj"] as? String {
            self.djID = _dj
        }
        
    }
    
    
    func getJSON() -> [String: Any] {
        
        var dictionary = [String: Any]()
        
        if let djid = self.djID {
            dictionary[PartyJSON.dj.rawValue] = djid
        }
        
        if let n = self.name {
            dictionary[PartyJSON.name.rawValue] = n
        }
        
        if let location = self.location {
            dictionary[PartyJSON.location.rawValue] = location.getJSON()
        }
        
        dictionary[PartyJSON.publicParty.rawValue] = self.publicParty
        
        return dictionary
    }
    
    func bindID(_ id: String) throws {
        guard self.id != id else{
            return
        }
        
        if let r = self.realm {
            do{
                try r.write {
                    self.id = id
                }
            }catch{
                throw error
            }
        }else{
            self.id = id
        }
    }
    
    
    public func addLocation(_ loc: Location) {
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
    
    public func addName(_ n: String) throws {
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

