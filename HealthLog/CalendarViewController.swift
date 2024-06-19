import UIKit
import CoreData

class CalendarViewController: UIViewController {

    // MARK: - Properties

    private let calendarView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("<", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapPrevButton), for: .touchUpInside)
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(">", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()

    private let dietSummaryCard: SummaryCard = {
        let card = SummaryCard()
        card.titleLabel.text = "Diet Summary"
        return card
    }()

    private let exerciseSummaryCard: SummaryCard = {
        let card = SummaryCard()
        card.titleLabel.text = "Exercise Summary"
        return card
    }()

    private var context: NSManagedObjectContext!
    private var currentMonthStartDate: Date = Date()
    private var selectedDate: Date?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        setupCurrentMonth()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = .white
        title = "Calendar"

        setupMonthLabel()
        setupCalendarView()
        setupSummaryCards()

        let tapGestureDiet = UITapGestureRecognizer(target: self, action: #selector(didTapDietSummary))
        dietSummaryCard.addGestureRecognizer(tapGestureDiet)

        let tapGestureExercise = UITapGestureRecognizer(target: self, action: #selector(didTapExerciseSummary))
        exerciseSummaryCard.addGestureRecognizer(tapGestureExercise)

        NSLayoutConstraint.activate([
            prevButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            calendarView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 20),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 300),

            dietSummaryCard.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            dietSummaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dietSummaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dietSummaryCard.heightAnchor.constraint(equalToConstant: 100),  // 고정된 높이로 설정

            exerciseSummaryCard.topAnchor.constraint(equalTo: dietSummaryCard.bottomAnchor, constant: 20),
            exerciseSummaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exerciseSummaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exerciseSummaryCard.heightAnchor.constraint(equalToConstant: 100),  // 고정된 높이로 설정
            exerciseSummaryCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupMonthLabel() {
        view.addSubview(monthLabel)
        view.addSubview(prevButton)
        view.addSubview(nextButton)
    }

    private func setupCalendarView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let width = (view.frame.size.width - 6) / 7
        layout.itemSize = CGSize(width: width, height: width)

        calendarView.collectionViewLayout = layout
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")

        view.addSubview(calendarView)
    }

    private func setupSummaryCards() {
        view.addSubview(dietSummaryCard)
        dietSummaryCard.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(exerciseSummaryCard)
        exerciseSummaryCard.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupCurrentMonth() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: currentMonthStartDate)
    }

    // MARK: - Data Methods

    private func updateSummaries(for date: Date) {
        loadDietSummary(for: date)
        loadExerciseSummary(for: date)
        view.setNeedsLayout()
    }

    private func loadDietSummary(for date: Date) {
        let fetchRequest: NSFetchRequest<DietEntryEntity> = DietEntryEntity.fetchRequest()

        do {
            let entries = try context.fetch(fetchRequest).filter {
                Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date)
            }
            let totalCalories = entries.reduce(0) { $0 + $1.calories }
            dietSummaryCard.bodyLabel.text = "Total Calories: \(totalCalories)"
        } catch {
            print("Failed to fetch diet entries: \(error)")
        }
    }

    private func loadExerciseSummary(for date: Date) {
        let fetchRequest: NSFetchRequest<ExerciseEntryEntity> = ExerciseEntryEntity.fetchRequest()

        do {
            let entries = try context.fetch(fetchRequest).filter {
                Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date)
            }
            let totalCalories = entries.reduce(0) { $0 + $1.calories }
            exerciseSummaryCard.bodyLabel.text = "Total Calories Burned: \(totalCalories)"
        } catch {
            print("Failed to fetch exercise entries: \(error)")
        }
    }

    // MARK: - Action Methods

    @objc private func didTapDietSummary() {
        guard let date = selectedDate else { return }
        let dietDetailsViewController = DietDetailsViewController()
        dietDetailsViewController.selectedDate = date
        navigationController?.pushViewController(dietDetailsViewController, animated: true)
    }

    @objc private func didTapExerciseSummary() {
        guard let date = selectedDate else { return }
        let exerciseDetailsViewController = ExerciseDetailsViewController()
        exerciseDetailsViewController.selectedDate = date
        navigationController?.pushViewController(exerciseDetailsViewController, animated: true)
    }

    @objc private func didTapPrevButton() {
        currentMonthStartDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthStartDate)!
        setupCurrentMonth()
        calendarView.reloadData()
    }

    @objc private func didTapNextButton() {
        currentMonthStartDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthStartDate)!
        setupCurrentMonth()
        calendarView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: currentMonthStartDate)!
        return range.count + startDayOffset()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell

        let day = indexPath.item - startDayOffset() + 1
        cell.dayLabel.text = day > 0 ? "\(day)" : ""
        
        if let selectedDate = selectedDate, day > 0 {
            let cellDate = getDateFor(day: day)
            if Calendar.current.isDate(cellDate, inSameDayAs: selectedDate) {
                cell.updateSelection(isSelected: true)
            } else {
                cell.updateSelection(isSelected: false)
            }
        } else {
            cell.updateSelection(isSelected: false)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CalendarViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = indexPath.item - startDayOffset() + 1
        if day > 0 {
            selectedDate = getDateFor(day: day)
            updateSummaries(for: selectedDate!)
            collectionView.reloadData()  // 셀 선택 상태를 업데이트하기 위해 추가
        }
    }

    private func startDayOffset() -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: currentMonthStartDate)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
    }

    private func getDateFor(day: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month], from: currentMonthStartDate)
        components.day = day
        return Calendar.current.date(from: components)!
    }
}

class SummaryCard: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0  // 여러 줄을 허용하지만 고정된 높이로 설정
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(named: "CustomTintColor")
        layer.cornerRadius = 10
        addSubview(titleLabel)
        addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bodyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CalendarCell: UICollectionViewCell {

    let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet {
            updateSelection(isSelected: isSelected)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(dayLabel)

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateSelection(isSelected: Bool) {
        dayLabel.textColor = isSelected ? .white : .black
        contentView.backgroundColor = isSelected ? .tintColor : .clear
        contentView.layer.cornerRadius = 60
    }
}
