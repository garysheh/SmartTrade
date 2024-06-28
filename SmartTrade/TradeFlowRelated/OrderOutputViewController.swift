//
//  OrderOutputViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/27.
//

import UIKit

class OrderOutputViewController: UIViewController {
    
    @IBOutlet weak var OutputLimitOrder: UILabel!
    @IBOutlet weak var OutputMarketOrder: UILabel!
    @IBOutlet weak var balanceField: UILabel!
    @IBOutlet weak var availableShareField: UILabel!
    @IBOutlet weak var outputAmountLabel: UILabel!
    @IBOutlet weak var outputSharesLabel: UILabel!
    @IBOutlet weak var outputSharesIcon: UIImageView!
    @IBOutlet weak var outputOrderTypeLabel: UILabel!
    @IBOutlet weak var outputTotalLabel: UILabel!
    @IBOutlet weak var outputSharesForBottomLabel: UILabel!
    @IBOutlet weak var outputpriceLabel: UILabel!
    
    
    // UI INTERFACE LOGIC
    
        private var currentViewController1: UIViewController?
        private var currentViewController2: UIViewController?
        
        private var marketOrderViewController: UIViewController?
        private var limitOrderViewController: UIViewController?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupRoundedLabel(labels: [balanceField,availableShareField])
            highlightMarketOrder()
            setupGestureRecognizers()
            
        }
        
        @objc private func marketOrderTapped() {
            highlightMarketOrder()
            updateOrderTypeLabel(to: "Market Order")
        }

        @objc private func limitOrderTapped() {
            highlightLimitOrder()
            updateOrderTypeLabel(to: "Limit Order")
        }
    
        @objc private func sharesTapped() {
            toggleAmountAndShares()
        }
        
        private func toggleAmountAndShares() {
            if outputAmountLabel.text == "  Shares" {
                outputAmountLabel.text = "  Amount"
                outputSharesLabel.text = "Shares"
            } else {
                outputSharesLabel.text = "  Shares"
                outputSharesLabel.text = "Amount"
            }
        }
    
        private func updateUnitLabel(to orderType: String) {
            outputAmountLabel.text = orderType
        }
    
        private func updateOrderTypeLabel(to orderType: String) {
            outputOrderTypeLabel.text = orderType
        }
        
        private func highlightMarketOrder() {
            OutputMarketOrder.textColor = .white
            OutputLimitOrder.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func highlightLimitOrder() {
            OutputLimitOrder.textColor = .white
            OutputMarketOrder.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func setupGestureRecognizers() {
            let marketOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(marketOrderTapped))
            OutputMarketOrder.isUserInteractionEnabled = true
            OutputMarketOrder.addGestureRecognizer(marketOrderTapGesture)
            
            let limitOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(limitOrderTapped))
            OutputLimitOrder.isUserInteractionEnabled = true
            OutputLimitOrder.addGestureRecognizer(limitOrderTapGesture)
            
            let sharesLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(sharesTapped))
            outputSharesLabel.isUserInteractionEnabled = true
            outputSharesLabel.addGestureRecognizer(sharesLabelTapGesture)
                    
                    let sharesIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(sharesTapped))
            outputSharesIcon.isUserInteractionEnabled = true
            outputSharesIcon.addGestureRecognizer(sharesIconTapGesture)
        }
    
        private func setupRoundedLabel(labels: [UILabel]) {
            for label in labels {
                label.layer.cornerRadius = 10 // Adjust the radius as needed
                label.layer.masksToBounds = true
            }
        }
    
    
    @IBAction func placeSellTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "PlaceSuccessfullyViewController") as? PlaceSuccessfullyViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // BUY AND SELL PART

}
