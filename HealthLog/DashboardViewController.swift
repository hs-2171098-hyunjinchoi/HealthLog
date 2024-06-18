import UIKit
import CoreData

class DashboardViewController: UIViewController {

    // MARK: - Properties
    let greetingLabel = UILabel()
    let dietSummaryView = UIView()
    let exerciseSummaryView = UIView()
    var dietSummaryLabel = UILabel()
    var exerciseSummaryLabel = UILabel()
    var context: NSManagedObjectContext!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        loadDietSummary()
        loadExerciseSummary()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDietSummary()
        loadExerciseSummary()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Home"

        // Greeting Label
        greetingLabel.text = "Today's Summary"
        greetingLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(greetingLabel)

        // Diet Summary View
        dietSummaryView.backgroundColor = .lightGray
        dietSummaryView.layer.cornerRadius = 10
        dietSummaryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dietSummaryView)

        // Diet Summary Label
        dietSummaryLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        dietSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        dietSummaryView.addSubview(dietSummaryLabel)

        // Exercise Summary View
        exerciseSummaryView.backgroundColor = .lightGray
        exerciseSummaryView.layer.cornerRadius = 10
        exerciseSummaryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exerciseSummaryView)

        // Exercise Summary Label
        exerciseSummaryLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        exerciseSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        exerciseSummaryView.addSubview(exerciseSummaryLabel)

        // Constraints
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            greetingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            dietSummaryView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 20),
            dietSummaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dietSummaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dietSummaryView.heightAnchor.constraint(equalToConstant: 150),

            dietSummaryLabel.centerXAnchor.constraint(equalTo: dietSummaryView.centerXAnchor),
            dietSummaryLabel.centerYAnchor.constraint(equalTo: dietSummaryView.centerYAnchor),

            exerciseSummaryView.topAnchor.constraint(equalTo: dietSummaryView.bottomAnchor, constant: 20),
            exerciseSummaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exerciseSummaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exerciseSummaryView.heightAnchor.constraint(equalToConstant: 150),

            exerciseSummaryLabel.centerXAnchor.constraint(equalTo: exerciseSummaryView.centerXAnchor),
            exerciseSummaryLabel.centerYAnchor.constraint(equalTo: exerciseSummaryView.centerYAnchor)
        ])

        let dietTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDietSummary))
        dietSummaryView.addGestureRecognizer(dietTapGesture)

        let exerciseTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapExerciseSummary))
        exerciseSummaryView.addGestureRecognizer(exerciseTapGesture)
    }

    private func loadDietSummary() {
        let fetchRequest: NSFetchRequest<DietEntryEntity> = DietEntryEntity.fetchRequest()
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!

        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", todayStart as CVarArg, todayEnd as CVarArg)

        do {
            let todayEntries = try context.fetch(fetchRequest)
            let totalCalories = todayEntries.reduce(0) { $0 + $1.calories }
            dietSummaryLabel.text = "Today's Total Calories: \(totalCalories)"
        } catch {
            print("Failed to fetch diet entries: \(error)")
        }
    }

    private func loadExerciseSummary() {
        let fetchRequest: NSFetchRequest<ExerciseEntryEntity> = ExerciseEntryEntity.fetchRequest()
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!

        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", todayStart as CVarArg, todayEnd as CVarArg)

        do {
            let todayEntries = try context.fetch(fetchRequest)
            let totalCalories = todayEntries.reduce(0) { $0 + $1.calories }
            exerciseSummaryLabel.text = "Today's Total Exercise Calories: \(totalCalories)"
        } catch {
            print("Failed to fetch exercise entries: \(error)")
        }
    }

    @objc private func didTapDietSummary() {
        let dietDetailsViewController = DietDetailsViewController()
        dietDetailsViewController.selectedDate = Calendar.current.startOfDay(for: Date()) // Set the selected date
        navigationController?.pushViewController(dietDetailsViewController, animated: true)
    }

    @objc private func didTapExerciseSummary() {
        let exerciseDetailsViewController = ExerciseDetailsViewController()
        exerciseDetailsViewController.selectedDate = Calendar.current.startOfDay(for: Date()) // Set the selected date
        navigationController?.pushViewController(exerciseDetailsViewController, animated: true)
    }
}
