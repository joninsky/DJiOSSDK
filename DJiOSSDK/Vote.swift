//
//  Vote.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 1/23/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift


public class Vote: Object {
    
    dynamic public internal(set) var voterID: String?
    
    dynamic public internal(set) var userName: String?
    
    dynamic public internal(set) var rawVoteType = 0
    
    public var voteType: VoteType {
        get{
            guard let vote = VoteType(rawValue: self.rawVoteType) else {
                return VoteType.unknown
            }
            return vote
        }
        
        set(value){
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.rawVoteType = value.rawValue
                    }
                }catch{
                    
                }
            }else{
                self.rawVoteType = value.rawValue
            }
        }
    }
    
    dynamic public private(set) var time: Date?
    
    internal var parties = LinkingObjects(fromType: Party.self, property: "votes")
    
    public var party: Party? {
        return self.parties.first
    }
    
    dynamic public internal(set) var valid = true
    
    public var isUsersVote: Bool {
        guard let userID = User.loggedInUser()?.id else {
            return false
        }
        
        return (userID == self.voterID)
        
    }
    
    public convenience init?(withDictionary d: [String: Any]) {
        self.init()
        
        
        do{
            try self.crackJSON(d)
        }catch{
            return nil
        }
        
    }
    
    
    func crackJSON(_ JSON: [String: Any]) throws {
        
        let keys = VoteJSON()
        
        if let type = JSON[keys.voteType] as? Int, let actualType = VoteType(rawValue: type) {

            self.voteType = actualType
        }
        
        
        if let id = JSON[keys.voterID] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.voterID = id
                    }
                }catch{
                    
                }
            }else{
                self.voterID = id
            }
        }
        
        if let name = JSON[keys.userName] as? String {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.userName = name
                    }
                }catch{
                    
                }
            }else{
                self.userName = name
            }
        }
        
        
        if let theTime = JSON[keys.time] as? Date {
            if let realm = self.realm {
                do{
                    try realm.write {
                        self.time = theTime
                    }
                }catch{
                    
                }
            }else{
                self.time = theTime
            }
        }

    }
    
    
    func siphonJSON() -> [String: Any] {
        
        let keys = VoteJSON()
        
        return [keys.voterID: self.voterID, keys.voteType: self.rawVoteType, keys.time: self.time]
        
        
    }
    

    public func invalidte() {
        if let realm = self.realm {
            do{
                try realm.write {
                    self.valid = false
                }
            }catch{
                
            }
        }else{
            self.valid = false
        }
    }
    
    
}
