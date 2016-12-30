//
//  Enumerations.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation


public enum NetworkError: Error {
    case noInternet
    case badURL
    case badConfiguration
    case couldNotSetPOSTBody(e: Error?)
    case requestError(e: Error?)
    case badResponse(code: Int?)
    case failedToParseJSON
    case realmError(e: Error?)
}

public enum InternetStatus {
    case notReachable
    case reachableViaWWAN
    case reachableViaWiFi
}

enum HTTPMethod: String {
    case POST = "POST"
    case PUT = "PUT"
    case GET = "GET"
    case DELETE = "DELETE"
}

enum UserJSON: String {
    case name = "name"
    case djName = "djName"
    case email = "email"
    case facebook_id = "facebook_id"
    case facebook_login = "facebook_login"
    case facebookToken = "facebookToken"
    case spotify_login = "spotify_login"
    case djscore = "djscore"
    case pushToken = "pushToken"
    case pushSandbox = "pushSandbox"
    case parties = "parties"
    case created_at = "created_at"
    case updated_at = "updated_at"
}

enum PartyJSON: String {
    case name = "partyName"
    case dj = "dj"
    case participants = "participants"
    case location = "location"
    case active = "active"
    case created_at = "created_at"
    case updated_at = "updated_at"
}



public enum LogOutError: Error {
    case noRealm
    case realmError(e: Error)
}

public enum LogInError: Error {
    case noRealm
    case realmError(e: Error)
}
