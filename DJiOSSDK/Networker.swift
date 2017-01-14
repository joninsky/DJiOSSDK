//
//  Networker.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation


public class Networker {
    //MARK: Properties
    
    let session = URLSession.shared
    let mainQueue = DispatchQueue.main
    
    //Home Network
    //let urlString = "http://192.168.0.2:8080/api"
    //Local Host
    //let urlString = "http://localhost:8080/api"
    //Live AWS
    let urlString = "http://ec2-35-165-240-107.us-west-2.compute.amazonaws.com:8080/api"
    
    //MARK: Header Stuff
    let contentTypeValue = "application/json"
    let contentTypeHeader = "Content-Type"
    
    //MARK: Initalier
    public init(){
        
        
        
    }
    
    
    
}
