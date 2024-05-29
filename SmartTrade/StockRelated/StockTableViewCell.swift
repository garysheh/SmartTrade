import UIKit

class StockTableViewCell: UITableViewCell {
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var assetHighLabel: UILabel!
    
    func configure(with searchResult: SearchResult) {
        assetNameLabel.text = "\(String(describing: searchResult.price))"
        assetSymbolLabel.text = searchResult.symbol
        assetTypeLabel.text = "HIGH: \(String(describing: searchResult.low))"
        assetHighLabel.text = "LOW: \(String(describing: searchResult.high))"
    }
}
