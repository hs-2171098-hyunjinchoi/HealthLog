import UIKit
import CoreData

class ExerciseAnalysisViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Properties
    private let periods = ["Last Week", "Last Month", "Last 3 Months", "Last 6 Months", "Last Year"]
    private let metrics = ["Calories Burned", "Days with Exercise"]
    private let periodPicker = UIPickerView()
    private let metricPicker = UIPickerView()
    
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
        label.text = "Do or not"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
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
    
    private var exercises: [ExerciseEntryEntity] = []
    private var dataByDay: [String: Double] = [:]
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadExerciseData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawLineChart(with: dataByDay)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Exercise Analysis"
        
        periodPicker.delegate = self
        periodPicker.dataSource = self
        metricPicker.delegate = self
        metricPicker.dataSource = self
        
        view.addSubview(periodPicker)
        view.addSubview(metricPicker)
        view.addSubview(lineChartView)
        view.addSubview(yAxisLabel)
        view.addSubview(xAxisLabel)
        
        periodPicker.translatesAutoresizingMaskIntoConstraints = false
        metricPicker.translatesAutoresizingMaskIntoConstraints = false
        
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2) // y축 레이블을 세로로 회전
        
        NSLayoutConstraint.activate([
            periodPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            periodPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            periodPicker.widthAnchor.constraint(equalToConstant: 150),
            
            metricPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            metricPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            metricPicker.widthAnchor.constraint(equalToConstant: 150),
            
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
    private func loadExerciseData() {
        let fetchRequest: NSFetchRequest<ExerciseEntryEntity> = ExerciseEntryEntity.fetchRequest()
        
        // Fetch exercises from the selected period
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
            exercises = try context.fetch(fetchRequest)
            analyzeData()
        } catch {
            print("Failed to fetch exercise data: \(error)")
        }
    }
    
    private func analyzeData() {
        // Aggregate data by day
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dataByDay.removeAll()
        let selectedMetric = metricPicker.selectedRow(inComponent: 0)
        
        for exercise in exercises {
            let dateKey = dateFormatter.string(from: exercise.date!)
            switch selectedMetric {
            case 0: // Calories Burned
                dataByDay[dateKey, default: 0] += exercise.calories
                yAxisLabel.text = "Calories"
            case 1: // Days with Exercise
                dataByDay[dateKey, default: 0] = 1
                yAxisLabel.text = "Do or not"
            default:
                dataByDay[dateKey, default: 0] += exercise.calories
                yAxisLabel.text = "Calories"
            }
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
            if dataByDay[dateKey] == nil {
                dataByDay[dateKey] = 0
            }
        }
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
        
        let margin: CGFloat = 20.0 // Add margin to avoid labels going out of the view
        let chartWidth = lineChartView.frame.width - margin * 2
        
        for (index, key) in sortedKeys.enumerated() {
            let xPosition = CGFloat(index) * (chartWidth / CGFloat(sortedKeys.count - 1)) + margin
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
                dayLabel.frame = CGRect(x: xPosition - 30, y: lineChartView.frame.height + 5, width: 60, height: 20)
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }

        label.font = UIFont.systemFont(ofSize: 12) // 글자 크기 줄이기
        label.text = pickerView == periodPicker ? periods[row] : metrics[row]
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true // 글자가 잘리지 않도록 조정
        return label
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == periodPicker ? periods.count : metrics.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == periodPicker ? periods[row] : metrics[row]
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadExerciseData()
        drawLineChart(with: dataByDay)
    }
}
