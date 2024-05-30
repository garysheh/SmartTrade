import UIKit

class StockTableViewCell: UITableViewCell {
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var assetHighLabel: UILabel!
    @IBOutlet weak var assetLatestLabel: UILabel!
    func configure(with searchResult: SearchResult) {
        assetNameLabel.text = "\(String(describing: searchResult.price))"
        assetSymbolLabel.text = searchResult.symbol
        assetTypeLabel.text = "LOW: \(String(describing: searchResult.low))"
        assetHighLabel.text = "HIGH: \(String(describing: searchResult.high))"
        assetLatestLabel.text = "Latest Trade Day: \(String(describing: searchResult.day))"
    }
}
