//
//  TradeHistoryViewController.swift
//  SmartTrade
//
//  Created by Frank Leung on 25/6/2024.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class TradeHistoryViewController: UIViewController {
    
    
    var stockData: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setDefault(){
        print(stockData)
        let db = Firestore.firestore()
        let email = Auth.auth().currentUser?.email
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
