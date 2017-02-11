//
//  NotificationHandle.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 1/16/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import Foundation
import UserNotifications


public let VoteNotification = NSNotification.Name(rawValue: "VoteNotificaiton")

public let InvitationNotification = NSNotification.Name(rawValue: "InvitationReceived")

public let UpdateNotification = NSNotification.Name(rawValue: "UpdateNotification")

public let RequestNotification = NSNotification.Name(rawValue: "RequestNotification")

public class NotificationHandle: NSObject, UNUserNotificationCenterDelegate {
    
    //MARK: Properties
    
    public static let shared = NotificationHandle()
    
    
    
    public internal(set) var theToken: String?
    
    //MARK: Init
    override init() {
        super.init()
        
    }
    
    
    //MARK: Custom Functions
    public func configureNotifications() {
        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (didComplete, error) in
                if error == nil {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            })
        }else{
            let notificaitonSettigs = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificaitonSettigs)
        }
    }
    
    
    public func setUpRemoteNotifications(withDeviceTokenData deviceToken: Data) {
        
        
        var hexString = ""
        for b in deviceToken.enumerated() {
            hexString += String(format: "%02x", b.element)
        }
        
        if let user = User.loggedInUser() {
            user.updatePushNotificationToken(hexString, sandBox: self.isSandBox(), completion: { (error) in
                
                print(error)
            })
        }else{
            self.theToken = hexString
        }
        
    }
    
    
    
    public func handleNotificaiton(_ userInfo: [AnyHashable: Any],  completion: @escaping (_ results: UIBackgroundFetchResult) -> Void){
        
        print(userInfo)
        
        guard let packet = userInfo["aps"] as? [String:AnyObject] else {
            completion(UIBackgroundFetchResult.noData)
            return
        }
        
        let alert = packet["alert"] as? String
        
        if let contentAvailable = packet["content-available"] as? Int {
           // print(contentAvailable)
        }
        
        if let voteType = userInfo["vote"] as? [String: Any] {
            
            
            guard let voteRaw = voteType["rawVote"] as? Int else{
                return
            }
            
            let keys = VoteJSON()
            
            var newVoteInfo: [String: Any] = [keys.time: Date(), keys.voteType: voteRaw]
            
            if let user = voteType["user"] as? String {
                newVoteInfo[keys.voterID] = user
            }
            
            if let userName = voteType["userName"] as? String {
                newVoteInfo[keys.userName] = userName
            }
            
            
            guard let vote = Vote(withDictionary: newVoteInfo) else{
                return
            }
            
            do{
                try User.loggedInUser()?.myParty?.addVote(theVote: vote)
                try User.loggedInUser()?.participatingParty?.addVote(theVote: vote)
            }catch{
                
            }
        }
        
        if let partyInfo = userInfo["invitation"] as? [String: Any] {
            guard let invitedParty = Party(withDictionary: partyInfo) else {
                completion(UIBackgroundFetchResult.failed)
                return
            }
            
            do{
                try User.loggedInUser()?.addInvitation(invitedparty: invitedParty)
                NotificationCenter.default.post(name: InvitationNotification, object: nil)
            }catch{
                completion(UIBackgroundFetchResult.failed)
                return
            }
        }
        
        if let freshParty = userInfo["party"] as? [String: Any] {
            do{
                try User.loggedInUser()?.participatingParty?.crackJSON(theJSON: freshParty)
                NotificationCenter.default.post(name: UpdateNotification, object: nil)
            }catch{
                
            }
        }
        completion(UIBackgroundFetchResult.newData)
    }
    
    
    public func isSandBox() -> Bool {
        guard let filePath = Bundle.main.path(forResource: "embedded", ofType:"mobileprovision") else {
            return false
        }
        do {
            let url = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .ascii) else {
                return false
            }
            if string.contains("<key>aps-environment</key>\n\t\t<string>development</string>") {
                return true
            }
        } catch {}
        return false
    }
    
    
    public func sendQuickNotification(_ body: String) {
        let content = UNMutableNotificationContent()
        content.body = body
        content.categoryIdentifier = "Quick"
        let request = UNNotificationRequest(identifier: "Quick", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}
