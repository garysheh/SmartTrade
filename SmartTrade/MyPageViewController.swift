//
//  MyPageViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/17.
//

import UIKit

class MyPageViewController: UIViewController {
    @IBOutlet weak var marketData: UILabel!
    
    @IBOutlet weak var myRewards: UILabel!
    
    @IBOutlet weak var alerts: UILabel!
    
    @IBOutlet weak var coupons: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var saved: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoundedLabel(labels: [marketData,myRewards,alerts,coupons,history,saved])
        // Do any additional setup after loading the view.
    }
    
    private func setupRoundedLabel(labels: [UILabel]) {
        for label in labels {
            label.layer.cornerRadius = 10 // Adjust the radius as needed
            label.layer.masksToBounds = true
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
