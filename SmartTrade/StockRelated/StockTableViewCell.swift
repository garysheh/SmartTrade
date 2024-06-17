import UIKit
import DGCharts
import Charts
import Combine

class StockTableViewCell: UITableViewCell {
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetPercentLabel: UILabel!
    @IBOutlet weak var assetHighLabel: UILabel!
    @IBOutlet weak var assetLatestLabel: UILabel!
    @IBOutlet weak var priceChart: UIView!
    
    private let separator: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    private let lineChartView: LineChartView = {
            let chartView = LineChartView()
            chartView.translatesAutoresizingMaskIntoConstraints = false
            return chartView
        }()
    
    private var cancellable: AnyCancellable? = nil
    private let apiService = APIService()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSeparator()
        setupChart()
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
    
    private func setupChart() {
        priceChart.addSubview(lineChartView)

        NSLayoutConstraint.activate([
            lineChartView.leadingAnchor.constraint(equalTo: priceChart.leadingAnchor),
            lineChartView.trailingAnchor.constraint(equalTo: priceChart.trailingAnchor),
            lineChartView.topAnchor.constraint(equalTo: priceChart.topAnchor),
            lineChartView.bottomAnchor.constraint(equalTo: priceChart.bottomAnchor)
        ])

        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.chartDescription.enabled = false
        lineChartView.setScaleEnabled(false)
        lineChartView.drawGridBackgroundEnabled = false
    }
    
    func configure(with searchResult: SearchResult) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        assetNameLabel.text = String(format: "%.2f", Double(searchResult.price)!)
        assetSymbolLabel.text = searchResult.symbol
        assetPercentLabel.text = searchResult.percent
        // Remove the percentage sign and safely unwrap and format the percent
            let percentString = searchResult.percent.replacingOccurrences(of: "%", with: "")
            if let percent = Double(percentString) {
                let formattedPercent = formatter.string(from: NSNumber(value: percent)) ?? "N/A"
                assetPercentLabel.text = "\(formattedPercent)%"
                assetPercentLabel.textColor = percent >= 0 ? UIColor(red: 27/255, green: 187/255, blue: 125/255, alpha: 1.0) : UIColor(red: 240/255, green: 57/255, blue: 85/255, alpha: 1.0)
                // format the price color changes
                assetNameLabel.textColor = percent >= 0 ? UIColor(red: 27/255, green: 187/255, blue: 125/255, alpha: 1.0) : UIColor(red: 240/255, green: 57/255, blue: 85/255, alpha: 1.0)
            } else {
                assetPercentLabel.text = "N/A"
                assetPercentLabel.textColor = UIColor.white // Default color if percentage is unavailable
            }
        fetchDailyPriceData(for: searchResult.symbol)
    }
    
        override func setSelected(_ selected: Bool, animated: Bool) { // Override setSelected to handle cell selection
            super.setSelected(selected, animated: animated)
            
            if selected {
                contentView.backgroundColor = UIColor.lightGray // Change to desired selection color
            } else {
                contentView.backgroundColor = UIColor.clear // Revert to original color
            }
        }
    
    private func fetchDailyPriceData(for symbol: String) {
            cancellable = apiService.fetchDailyPricesPublisher(symbol: symbol)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error fetching daily prices: \(error)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] prices in
                    self?.updateChart(with: prices)
                })
        }
    
    private func updateChart(with prices: [Double]) {
        guard prices.count >= 2 else {
            // Not enough data to calculate percentage change
            return
        }

        // Calculate percentage change from yesterday
        let yesterdayPrice = prices[prices.count - 2]
        let latestPrice = prices.last!
        let percentageChange = ((latestPrice - yesterdayPrice) / yesterdayPrice) * 100

        // Determine the color based on percentage change
        let lineColor: UIColor
        if percentageChange >= 0 {
            lineColor = UIColor(red: 27/255, green: 187/255, blue: 125/255, alpha: 1.0) // Green color
        } else {
            lineColor = UIColor(red: 240/255, green: 57/255, blue: 85/255, alpha: 1.0) // Red color
        }

        let entries = prices.enumerated().map { index, price in
            return ChartDataEntry(x: Double(index), y: price)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")

        // Customize the line with specific conditional color
        dataSet.colors = [lineColor]
        dataSet.lineWidth = 1.0
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false

        // Add gradient fill
        let gradientColors = [lineColor.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: nil)
        dataSet.fill = LinearGradientFill(gradient: gradient!, angle: 90)
        dataSet.drawFilledEnabled = true

        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        lineChartView.notifyDataSetChanged()
    }
}
