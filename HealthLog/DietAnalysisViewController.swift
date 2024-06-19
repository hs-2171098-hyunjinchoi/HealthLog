import UIKit
import CoreData

class DietAnalysisViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Properties
    private let periods = ["Last Week", "Last Month", "Last 3 Months", "Last 6 Months", "Last Year"]
    private let periodPicker = UIPickerView()
    
    private let lineChartView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    private let yAxisLabel: UILabel = {
        let label = UILabel()
        label.text = "Calories"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let xAxisLabel: UILabel = {
        let label = UILabel()
        label.text = "Dates"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var dietEntries: [DietEntryEntity] = []
    private var caloriesByDay: [String: Double] = [:]
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDietData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawLineChart(with: caloriesByDay)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Diet Analysis"
        
        periodPicker.delegate = self
        periodPicker.dataSource = self
        
        view.addSubview(periodPicker)
        view.addSubview(lineChartView)
        view.addSubview(yAxisLabel)
        view.addSubview(xAxisLabel)
        
        periodPicker.translatesAutoresizingMaskIntoConstraints = false
        
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2) // y축 레이블을 세로로 회전
        
        NSLayoutConstraint.activate([
            periodPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            periodPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            periodPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            periodPicker.heightAnchor.constraint(equalToConstant: 100),
            
            yAxisLabel.centerYAnchor.constraint(equalTo: lineChartView.centerYAnchor), // 중앙에 위치
            yAxisLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            yAxisLabel.widthAnchor.constraint(equalToConstant: 60),
            
            lineChartView.topAnchor.constraint(equalTo: periodPicker.bottomAnchor, constant: 20),
            lineChartView.leadingAnchor.constraint(equalTo: yAxisLabel.trailingAnchor, constant: 10),
            lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lineChartView.heightAnchor.constraint(equalToConstant: 300),
            
            xAxisLabel.topAnchor.constraint(equalTo: lineChartView.bottomAnchor, constant: 10),
            xAxisLabel.leadingAnchor.constraint(equalTo: lineChartView.leadingAnchor),
            xAxisLabel.trailingAnchor.constraint(equalTo: lineChartView.trailingAnchor)
        ])
    }

    // MARK: - Data Methods
    private func loadDietData() {
        let fetchRequest: NSFetchRequest<DietEntryEntity> = DietEntryEntity.fetchRequest()
        
        // Fetch diet data from the selected period
        let calendar = Calendar.current
        let now = Date()
        let selectedPeriod = periodPicker.selectedRow(inComponent: 0)
        let startDate: Date
        
        switch selectedPeriod {
        case 0: // Last Week
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case 1: // Last Month
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case 2: // Last 3 Months
            startDate = calendar.date(byAdding: .month, value: -3, to: now)!
        case 3: // Last 6 Months
            startDate = calendar.date(byAdding: .month, value: -6, to: now)!
        case 4: // Last Year
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        default:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        }
        
        let predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        fetchRequest.predicate = predicate
        
        do {
            dietEntries = try context.fetch(fetchRequest)
            caloriesByDay = analyzeData(dietEntries: dietEntries)
            drawLineChart(with: caloriesByDay)
        } catch {
            print("Failed to fetch diet data: \(error)")
        }
    }
    
    private func analyzeData(dietEntries: [DietEntryEntity]) -> [String: Double] {
        // Aggregate data by day
        var caloriesByDay: [String: Double] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for entry in dietEntries {
            let dateKey = dateFormatter.string(from: entry.date!)
            caloriesByDay[dateKey, default: 0] += entry.calories
        }
        
        // Ensure every day in the selected period is represented
        let calendar = Calendar.current
        let now = Date()
        let days: Int
        switch periodPicker.selectedRow(inComponent: 0) {
        case 0:
            days = 7
        case 1:
            days = 30
        case 2:
            days = 90
        case 3:
            days = 180
        case 4:
            days = 365
        default:
            days = 7
        }
        
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let dateKey = dateFormatter.string(from: date)
            if caloriesByDay[dateKey] == nil {
                caloriesByDay[dateKey] = 0
            }
        }
        
        return caloriesByDay
    }
    
    private func drawLineChart(with data: [String: Double]) {
        // Remove all sublayers before adding new ones
        lineChartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Remove all subviews before adding new ones
        for subview in lineChartView.subviews {
            subview.removeFromSuperview()
        }
        
        guard !data.isEmpty else { return }
        
        let maxDataValue = data.values.max() ?? 1 // Prevent division by zero
        let sortedKeys = data.keys.sorted()
        let path = UIBezierPath()
        
        for (index, key) in sortedKeys.enumerated() {
            let xPosition = CGFloat(index) * (lineChartView.frame.width / CGFloat(sortedKeys.count))
            let yPosition = lineChartView.frame.height - (CGFloat(data[key]!) / CGFloat(maxDataValue) * lineChartView.frame.height)
            
            if index == 0 {
                path.move(to: CGPoint(x: xPosition, y: yPosition))
            } else {
                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
            }
            
            // Add labels for the first and last date only to reduce clutter
            if index == 0 || index == sortedKeys.count - 1 {
                let dayLabel = UILabel()
                dayLabel.text = key
                dayLabel.font = UIFont.systemFont(ofSize: 8)
                dayLabel.textAlignment = .center
                dayLabel.frame = CGRect(x: xPosition - 20, y: lineChartView.frame.height + 5, width: 60, height: 20)
                lineChartView.addSubview(dayLabel)
            }
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        lineChartView.layer.addSublayer(shapeLayer)
        
        // Add Y-axis labels at the top and bottom only
        let yAxisTopLabel = UILabel()
        yAxisTopLabel.text = "\(Int(maxDataValue))"
        yAxisTopLabel.font = UIFont.systemFont(ofSize: 10)
        yAxisTopLabel.textAlignment = .right
        yAxisTopLabel.frame = CGRect(x: -40, y: 0, width: 30, height: 20)
        lineChartView.addSubview(yAxisTopLabel)
        
        let yAxisBottomLabel = UILabel()
        yAxisBottomLabel.text = "0"
        yAxisBottomLabel.font = UIFont.systemFont(ofSize: 10)
        yAxisBottomLabel.textAlignment = .right
        yAxisBottomLabel.frame = CGRect(x: -40, y: lineChartView.frame.height - 10, width: 30, height: 20)
        lineChartView.addSubview(yAxisBottomLabel)
    }
    
    // MARK: - UIPickerView Delegate & DataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return periods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }

        label.font = UIFont.systemFont(ofSize: 12) // 글자 크기 줄이기
        label.text = periods[row]
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true // 글자가 잘리지 않도록 조정
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadDietData()
        drawLineChart(with: caloriesByDay)
    }
}
