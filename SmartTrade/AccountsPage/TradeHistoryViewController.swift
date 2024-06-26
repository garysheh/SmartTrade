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
    
    let segmentedControl = UISegmentedControl(items: ["Buy", "Sell"])

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        segmentedControl.selectedSegmentIndex = 0
                
        // 添加 segmentedControl 到视图层次结构
        view.addSubview(segmentedControl)
                
        // 添加约束
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        // 设置背景颜色
        segmentedControl.backgroundColor = .black
        // 设置选中时的颜色
        segmentedControl.selectedSegmentTintColor = .systemGreen
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .selected)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
    }
    
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            // 处理选中选项变化的逻辑
            switch sender.selectedSegmentIndex {
            case 0:
                // 处理选中 "Option 1"
                print("0")
            case 1:
                // 处理选中 "Option 2"
                print("1")
            default:
                break
            }
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
