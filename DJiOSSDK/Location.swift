//
//  Location.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation
import RealmSwift



public class Location: Object {
    
    dynamic public internal(set) var locationName: String?
    
    dynamic public internal(set) var locationLatitude: Double = 0
    
    dynamic public internal(set) var locationLongitude: Double = 0
    
    
    
}
