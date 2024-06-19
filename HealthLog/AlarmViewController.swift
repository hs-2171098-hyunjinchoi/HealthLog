import UIKit
import CoreData
import UserNotifications

class AlarmViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private var alarms: [MyAlarmEntity] = []
    private let datePicker = UIDatePicker()
    private let addButton = UIButton(type: .system)
    private let titleTextField = UITextField()
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAlarms()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Alarm"
        
        setupTitleTextField()
        setupDatePicker()
        setupAddButton()
        setupTableView()
    }
    
    private func setupTitleTextField() {
        titleTextField.placeholder = "Enter title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .time
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupAddButton() {
        addButton.setTitle("Add Alarm", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AlarmCell.self, forCellReuseIdentifier: "AlarmCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Methods
    private func loadAlarms() {
        let fetchRequest: NSFetchRequest<MyAlarmEntity> = MyAlarmEntity.fetchRequest()
        
        do {
            alarms = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch alarms: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Action Methods
    @objc private func didTapAddButton() {
        let alarm = MyAlarmEntity(context: context)
        alarm.id = UUID().uuidString
        alarm.title = titleTextField.text ?? "No Title"
        alarm.time = datePicker.date
        
        alarms.append(alarm)
        saveContext()
        tableView.reloadData()
        
        // Schedule a local notification
        let content = UNMutableNotificationContent()
        content.title = "Health Log"
        content.body = alarm.title ?? "Alarm Time!"
        content.sound = .default
        content.categoryIdentifier = "ALARM_CATEGORY"
        
        let triggerDaily = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        let request = UNNotificationRequest(identifier: alarm.id!, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // Clear the input fields
        titleTextField.text = ""
    }
    
    private func deleteAlarm(at indexPath: IndexPath) {
        guard indexPath.row < alarms.count else {
            print("Invalid index")
            return
        }
        
        let alarmToDelete = alarms[indexPath.row]
        if let alarmId = alarmToDelete.id {
            // 알림 센터에서 알람을 제거
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmId])
        }
        
        // 알람을 배열에서 제거
        alarms.remove(at: indexPath.row)
        
        // 알람을 테이블 뷰에서 삭제
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // 코어 데이터에서 알람을 삭제
        context.delete(alarmToDelete)
        saveContext()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AlarmViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmCell
        let alarm = alarms[indexPath.row]
        cell.configure(with: alarm, deleteAction: { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.presentDeletionAlert(for: indexPath)
            }
        })
        return cell
    }
    
    private func presentDeletionAlert(for indexPath: IndexPath) {
        if let presentedViewController = presentedViewController, presentedViewController is UIAlertController {
            return
        }
        
        let alert = UIAlertController(title: "Delete Alarm", message: "Are you sure you want to delete this alarm?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteAlarm(at: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - AlarmCell
class AlarmCell: UITableViewCell {

    let titleLabel = UILabel()
    let timeLabel = UILabel()
    let deleteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with alarm: MyAlarmEntity, deleteAction: @escaping () -> Void) {
        titleLabel.text = alarm.title
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        timeLabel.text = dateFormatter.string(from: alarm.time!)
        deleteButton.addAction(UIAction { _ in deleteAction() }, for: .touchUpInside)
    }
}
