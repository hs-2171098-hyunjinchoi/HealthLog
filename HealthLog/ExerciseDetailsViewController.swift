import UIKit
import CoreData

class ExerciseDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedDate: Date?
    var exerciseEntries: [ExerciseEntryEntity] = []

    let dateLabel = UILabel()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Exercise Details"
        
        setupDateLabel()
        setupTableView()
        setupAddButton()
        
        if let selectedDate = selectedDate {
            loadExerciseEntries(for: selectedDate)
        }
    }

    private func setupDateLabel() {
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        if let selectedDate = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateLabel.text = dateFormatter.string(from: selectedDate)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExerciseEntryCell.self, forCellReuseIdentifier: "exerciseCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = addButton
    }

    @objc private func didTapAddButton() {
        let exerciseViewController = ExerciseViewController()
        exerciseViewController.selectedDate = selectedDate
        exerciseViewController.onSave = { [weak self] in
            self?.loadExerciseEntries(for: self?.selectedDate ?? Date())
        }
        navigationController?.pushViewController(exerciseViewController, animated: true)
    }

    internal func loadExerciseEntries(for date: Date) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ExerciseEntryEntity> = ExerciseEntryEntity.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            exerciseEntries = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch exercise entries: \(error)")
        }
    }

    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath) as! ExerciseEntryCell
        let entry = exerciseEntries[indexPath.row]
        cell.configure(with: entry)
        return cell
    }

    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = exerciseEntries[indexPath.row]
            presentDeletionAlert(for: entry, at: indexPath)
        }
    }

    private func presentDeletionAlert(for entry: ExerciseEntryEntity, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to delete this entry?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteEntry(entry, at: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func deleteEntry(_ entry: ExerciseEntryEntity, at indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(entry)
        
        do {
            try context.save()
            exerciseEntries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
}

class ExerciseEntryCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let caloriesLabel = UILabel()
    let detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        caloriesLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        caloriesLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        let verticalStackView = UIStackView(arrangedSubviews: [caloriesLabel, detailLabel])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 5
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

        let horizontalStackView = UIStackView(arrangedSubviews: [nameLabel, verticalStackView])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 10
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(horizontalStackView)

        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with entry: ExerciseEntryEntity) {
        nameLabel.text = entry.name
        caloriesLabel.text = "\(entry.calories) calories"
        detailLabel.text = entry.type == "Time" ? "\(entry.duration) minutes" : "\(entry.reps) repetitions"
    }
}
