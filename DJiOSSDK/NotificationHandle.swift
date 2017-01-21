//
//  NotificationHandle.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 1/16/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import Foundation
import UserNotifications

enum VoteType: Int {
    case skip = 0
    case replay = 1
    case replayPrevious = 2
    case approve = 3
}

let VoteNotification = NSNotification.Name(rawValue: "VoteNotificaiton")

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
            user.updatePushNotificationToken(hexString, production: !self.isDevelopmentEnvironment(), completion: { (error) in
                
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
            print(contentAvailable)
        }
        
        print(packet)
        
        if let voteType = userInfo["vote"] as? Int {
            guard let vote = VoteType(rawValue: voteType) else{
                return
            }
//            switch vote {
//            case VoteType.approve:
//                if let a = alert {
//                    let notificaiton = NotificationVote(a, type: .approve)
//                    NotificationCenter.default.post(name: VoteNotification, object: notificaiton)
//                }
//            case VoteType.skip:
//                MPMusicPlayerController.systemMusicPlayer().skipToNextItem()
//                if let a = alert {
//                    let notificaiton = NotificationVote(a, type: .skip)
//                    NotificationCenter.default.post(name: VoteNotification, object: notificaiton)
//                }
//            case VoteType.replay:
//                MPMusicPlayerController.systemMusicPlayer().skipToBeginning()
//                if let a = alert {
//                    let notificaiton = NotificationVote(a, type: .replay)
//                    NotificationCenter.default.post(name: VoteNotification, object: notificaiton)
//                }
//            case VoteType.replayPrevious:
//                MPMusicPlayerController.systemMusicPlayer().skipToPreviousItem()
//                if let a = alert {
//                    let notificaiton = NotificationVote(a, type: .replayPrevious)
//                    NotificationCenter.default.post(name: VoteNotification, object: notificaiton)
//                }
//            }
            print(vote)
        }
        
        if let invitation = packet["invitation"] as? [String:AnyObject] {
            print(invitation)
            
            if let partyID = invitation["id"] as? Int {
                print(partyID)
                
            }
        }
        completion(UIBackgroundFetchResult.newData)
    }
    
    
    public func isDevelopmentEnvironment() -> Bool {
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
    
    
}
