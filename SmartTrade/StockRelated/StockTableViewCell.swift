import UIKit

class StockTableViewCell: UITableViewCell {
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    
    func configure(with searchResult: SearchResult) {
        assetNameLabel.text = "\(String(describing: searchResult.price))"
        assetSymbolLabel.text = searchResult.symbol
        assetTypeLabel.text = "\(String(describing: searchResult.high))"
            .appending(" ")
            .appending("\(String(describing: searchResult.low))")
    }
}
