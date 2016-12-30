//
//  TransactionController.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation


public class TransactionController {
    
    public static let shared = TransactionController()
    
    init(){
        
    }
    
    internal func addNewTransaction(transaction t: Transaction) {
        
        guard let realm = Configuration.defaultConfiguration?.DJRealm else{
            return
        }
        
        do{
            try realm.write {
                realm.add(t)
            }
            
        }catch{
            return
        }
        
        
    }
    
    
    public func getTransactionHistory() -> [Transaction] {
        
        guard let realm = Configuration.defaultConfiguration?.DJRealm else {
            return []
        }
        
        let transactions = realm.objects(Transaction.self)
        
        return Array(transactions)
        
    }
}
