//
//  OrderInputViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/22.
//

import UIKit

class OrderInputViewController: UIViewController {
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var youPayField: UILabel!
    @IBOutlet weak var paymentField: UILabel!
    @IBOutlet weak var priceOrderType: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var sharesIcon: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    // UI INTERFACE LOGIC
    
        private var currentViewController1: UIViewController?
        private var currentViewController2: UIViewController?
        
        private var marketOrderViewController: UIViewController?
        private var limitOrderViewController: UIViewController?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupRoundedLabel(labels: [youPayField,paymentField])
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
            if amountLabel.text == "  Shares" {
                amountLabel.text = "  Amount"
                sharesLabel.text = "Shares"
            } else {
                amountLabel.text = "  Shares"
                sharesLabel.text = "Amount"
            }
        }
    
        private func updateUnitLabel(to orderType: String) {
            amountLabel.text = orderType
        }
    
        private func updateOrderTypeLabel(to orderType: String) {
            priceOrderType.text = orderType
        }
        
        private func highlightMarketOrder() {
            marketLabel.textColor = .white
            limitLabel.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func highlightLimitOrder() {
            limitLabel.textColor = .white
            marketLabel.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1.0) // Default color
        }
        
        private func setupGestureRecognizers() {
            let marketOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(marketOrderTapped))
            marketLabel.isUserInteractionEnabled = true
            marketLabel.addGestureRecognizer(marketOrderTapGesture)
            
            let limitOrderTapGesture = UITapGestureRecognizer(target: self, action: #selector(limitOrderTapped))
            limitLabel.isUserInteractionEnabled = true
            limitLabel.addGestureRecognizer(limitOrderTapGesture)
            
            let sharesLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(sharesTapped))
                    sharesLabel.isUserInteractionEnabled = true
                    sharesLabel.addGestureRecognizer(sharesLabelTapGesture)
                    
                    let sharesIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(sharesTapped))
                    sharesIcon.isUserInteractionEnabled = true
                    sharesIcon.addGestureRecognizer(sharesIconTapGesture)
        }
    
        private func setupRoundedLabel(labels: [UILabel]) {
            for label in labels {
                label.layer.cornerRadius = 10 // Adjust the radius as needed
                label.layer.masksToBounds = true
            }
        }
    
    
    // BUY AND SELL PART

}
