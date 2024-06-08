import UIKit

class StockTableViewCell: UITableViewCell {
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var assetHighLabel: UILabel!
    @IBOutlet weak var assetLatestLabel: UILabel!
    
    private let separator: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupSeparator()
        }
        
        private func setupSeparator() {
            contentView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    
    func configure(with searchResult: SearchResult) {
        assetNameLabel.text = "\(String(describing: searchResult.price))"
        assetSymbolLabel.text = searchResult.symbol
        assetTypeLabel.text = "LOW: \(String(describing: searchResult.low))"
        assetHighLabel.text = "HIGH: \(String(describing: searchResult.high))"
        assetLatestLabel.text = "Latest Trade Day: \(String(describing: searchResult.day))"
    }
    
        override func setSelected(_ selected: Bool, animated: Bool) { // Override setSelected to handle cell selection
            super.setSelected(selected, animated: animated)
            
            if selected {
                contentView.backgroundColor = UIColor.lightGray // Change to desired selection color
            } else {
                contentView.backgroundColor = UIColor.clear // Revert to original color
            }
        }
}
