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
import DGCharts

class TradeHistoryViewController: UIViewController {
    
    var tabBarIndex: Int?
    var stockSymbol: String?
    var stockData: [TradeOrder] = []
    private var barChartView: BarChartView!

    
    
    struct TradeOrder: Codable {
        let symbol: String
        let quantity: Double
        let timestamp: Timestamp
        let email: String
        let type: String
    }
    
    let segmentedControl = UISegmentedControl(items: ["Buy", "Sell"])
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSegmentedControl()
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
    }
    
    //setting the segmented controller
    private func setupSegmentedControl() {
            segmentedControl.selectedSegmentIndex = 0
            view.addSubview(segmentedControl)
            
            // add constraint
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            
            // set style
            segmentedControl.backgroundColor = .black
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
                setBarChartBuy()
            case 1:
                setBarChartSell()
                print("1")
            default:
                break
            }
        }
    
    
    //----------------------------------- sell ----------------------------------
    private func setBarChartSell(){
        
    }
    
    
    //----------------------------------- buy ----------------------------------
    private func setBarChartBuy(){
        
    }
    
    
    
    private func setDefault(){
        print(stockSymbol)
        let db = Firestore.firestore()
        let email = Auth.auth().currentUser?.email
        
        
        
    }
    

    

    // Navigation part
    
    
    private func setupCustomBackButton() {
            let backButton = UIButton(type: .system)
            let backButtonImage = UIImage(systemName: "house")
            backButton.setImage(backButtonImage, for: .normal)
            backButton.tintColor = .white
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            let backBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = backBarButtonItem
            print("Custom back button set up")
        }
    
    @objc private func backButtonTapped() {
            print("Back button tapped")
            loadTabBarController(atIndex: 0)
        }
        
        private func loadTabBarController(atIndex index: Int) {
            self.tabBarIndex = index
            self.performSegue(withIdentifier: "showTabBar", sender: self)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showTabBar" {
                if let tabBarController = segue.destination as? UITabBarController {
                    tabBarController.selectedIndex = self.tabBarIndex ?? 0
                }
            }
        }
}
