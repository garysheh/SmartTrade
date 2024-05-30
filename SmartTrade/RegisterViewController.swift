//
//  RegisterViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/4/30.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let firstname = FirstNameTextField.text else {return}
        guard let lastname = LastNameTextField.text else {return}
        
        Auth.auth().createUser(withEmail:email, password: password) { firebaseResult, error in
            if let e = error{
                print("error")
            }
            else{
                let db = Firestore.firestore()
                let uuid = UUID().uuidString
                db.collection("UserInfo").document(email).setData([
                    "FirstName": firstname,
                    "LastName": lastname,
                    "UUID": uuid,
                    "email":email,
                    "password":password
                  ])
                db.collection("Holdings").document(email).setData([
                    "email":email,
                    "holdings":[
                        ["stockCode":"AAPL","shares":50],
                        ["stockCode":"AMZN","shares":100]]
                ])
                //testing by setting default number
                
                
//                self.performSegue(withIdentifier:"goToNext", sender: self)
            }
        }
    
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
