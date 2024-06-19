import UIKit
import CoreData

class DietDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var selectedDate: Date?
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    let dateLabel = UILabel()
    let tableView = UITableView()
    var entries: [DietEntryEntity] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDateLabel()
        setupTableView()
        setupAddButton()
        loadDietEntries()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Diet Details"
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
        tableView.register(DietEntryCell.self, forCellReuseIdentifier: "dietCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80 // 적절한 예측 높이 설정
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
        let dietViewController = DietViewController()
        dietViewController.selectedDate = selectedDate
        dietViewController.onSave = { [weak self] in
            self?.loadDietEntries()
        }
        navigationController?.pushViewController(dietViewController, animated: true)
    }

    internal func loadDietEntries() {
        guard let selectedDate = selectedDate else { return }

        let fetchRequest: NSFetchRequest<DietEntryEntity> = DietEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", selectedDate as CVarArg, Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)! as CVarArg)

        do {
            entries = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch diet entries: \(error)")
        }
    }

    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dietCell", for: indexPath) as! DietEntryCell
        let entry = entries[indexPath.row]
        cell.configure(with: entry, deleteAction: { [weak self] in
            self?.presentDeletionAlert(for: entry, at: indexPath)
        })
        return cell
    }

    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = entries[indexPath.row]
            presentDeletionAlert(for: entry, at: indexPath)
        }
    }

    private func presentDeletionAlert(for entry: DietEntryEntity, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to delete this entry?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteEntry(entry, at: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func deleteEntry(_ entry: DietEntryEntity, at indexPath: IndexPath) {
        context.delete(entry)
        
        do {
            try context.save()
            entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
}


class DietEntryCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let caloriesLabel = UILabel()
    let entryImageView = UIImageView()
    let deleteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        caloriesLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        caloriesLabel.numberOfLines = 0
        caloriesLabel.translatesAutoresizingMaskIntoConstraints = false

        entryImageView.contentMode = .scaleAspectFill
        entryImageView.clipsToBounds = true
        entryImageView.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(entryImageView)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            entryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            entryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            entryImageView.widthAnchor.constraint(equalToConstant: 60),
            entryImageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.leadingAnchor.constraint(equalTo: entryImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: caloriesLabel.topAnchor, constant: -5),

            caloriesLabel.leadingAnchor.constraint(equalTo: entryImageView.trailingAnchor, constant: 10),
            caloriesLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            caloriesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            deleteButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    func configure(with entry: DietEntryEntity, deleteAction: @escaping () -> Void) {
        nameLabel.text = entry.name
        caloriesLabel.text = "\(entry.calories) calories"
        if let imageData = entry.image {
            entryImageView.image = UIImage(data: imageData)
        } else {
            entryImageView.image = UIImage(systemName: "photo")
        }
        deleteButton.addAction(UIAction { _ in deleteAction() }, for: .touchUpInside)
    }
}
