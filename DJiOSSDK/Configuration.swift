//
//  Configuration.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift

public class Configuration {
    
    static public let defaultConfiguration: Configuration? = Configuration()
    
    var DJRealm: Realm!
    
    public private(set) var AppID: String?
    
    let v: UInt64 = 16
    
    init?(){
        if let realmFileURL = self.configRealmFile() {
            let config = Realm.Configuration(fileURL: realmFileURL,
                                             readOnly: false,
                                             schemaVersion: self.v,
                                             migrationBlock: { migration, oldSchemaVersion in
                                                if (oldSchemaVersion < self.v) {
                                                    print("Realm Migrated!!")
                                                    // Nothing to do!
                                                    // Realm will automatically detect new properties and removed properties
                                                    // And will update the schema on disk automatically
                                                }
            })
            do{
                self.DJRealm = try Realm(configuration: config)
            }catch{
                print("Realm needs to migrate. \(error)")
                return nil
            }
        }else{
            return nil
        }
    }
    
    public func addAppID(_ id: String) {
        self.AppID = id
    }
    
    
    func configRealmFile() -> URL? {
        
        
        var documentsURL: URL!
        
        do {
            documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            
            return nil
        }
        
        
        let realmFileURL = documentsURL.appendingPathComponent("DJRealm.realm")
        
        
        if FileManager.default.fileExists(atPath: realmFileURL.path) {
            return realmFileURL
        }else if FileManager.default.createFile(atPath: realmFileURL.path, contents: nil, attributes: nil) {
            return realmFileURL
        }else{
            return nil
        }
    }
    
}

