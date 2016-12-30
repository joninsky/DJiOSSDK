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
    
    dynamic var id: String?
    
    dynamic var name: String?
    
    var location: Location?
    
    dynamic var active = false
    
    dynamic var created_at: Date?
    
    dynamic var updated_at: Date?
    
    private let owners = LinkingObjects(fromType: User.self, property: "usersParties")
    
    var owner: User? {
        return self.owners.first
    }
    
    
    var participants = List<User>()
    
    func getJSON() -> [String: Any] {
        return [PartyJSON.name.rawValue:self.name, PartyJSON.active.rawValue: self.active, PartyJSON.dj.rawValue: self.owner?.id, PartyJSON.location.rawValue: ["type": "Point", "coordinates": [self.location?.locationLongitude, self.location?.locationLatitude]]]
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
    
    func activate(_ activate: Bool) throws {
        guard self.active != activate else{
            return
        }
        
        if let r = self.realm {
            do{
                try r.write {
                    self.active = activate
                }
            }catch{
                throw error
            }
        }else{
            self.active = activate
        }
    }
    
    func addLocation(_ loc: Location) {
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
    
}

