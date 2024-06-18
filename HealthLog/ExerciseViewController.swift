import UIKit
import CoreData

class ExerciseViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    let nameTextField = UITextField()
    let caloriesTextField = UITextField()
    let typeSegmentedControl = UISegmentedControl(items: ["Time", "Reps"])
    let durationTextField = UITextField()
    let repsTextField = UITextField()
    let addButton = UIButton(type: .system)
    var context: NSManagedObjectContext!
    var selectedDate: Date? // 날짜를 선택할 수 있도록 변경
    var onSave: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        addDismissKeyboardTapGesture()
        typeSegmentedControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        typeSegmentedControl.selectedSegmentIndex = 0
        typeChanged()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Exercise Entry"

        // Name TextField
        nameTextField.placeholder = "Enter exercise name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.delegate = self
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)

        // Calories TextField
        caloriesTextField.placeholder = "Enter calories burned"
        caloriesTextField.borderStyle = .roundedRect
        caloriesTextField.keyboardType = .numberPad
        caloriesTextField.delegate = self
        caloriesTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(caloriesTextField)

        // Type Segmented Control
        typeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeSegmentedControl)

        // Duration TextField
        durationTextField.placeholder = "Enter duration (minutes)"
        durationTextField.borderStyle = .roundedRect
        durationTextField.keyboardType = .numberPad
        durationTextField.delegate = self
        durationTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(durationTextField)

        // Reps TextField
        repsTextField.placeholder = "Enter reps"
        repsTextField.borderStyle = .roundedRect
        repsTextField.keyboardType = .numberPad
        repsTextField.delegate = self
        repsTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(repsTextField)

        // Add Button
        addButton.setTitle("Add Exercise", for: .normal)
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        // Constraints
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            caloriesTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            caloriesTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            caloriesTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            typeSegmentedControl.topAnchor.constraint(equalTo: caloriesTextField.bottomAnchor, constant: 20),
            typeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            typeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            durationTextField.topAnchor.constraint(equalTo: typeSegmentedControl.bottomAnchor, constant: 20),
            durationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            durationTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            repsTextField.topAnchor.constraint(equalTo: typeSegmentedControl.bottomAnchor, constant: 20),
            repsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            repsTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            addButton.topAnchor.constraint(equalTo: durationTextField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func typeChanged() {
        if typeSegmentedControl.selectedSegmentIndex == 0 {
            durationTextField.isHidden = false
            repsTextField.isHidden = true
        } else {
            durationTextField.isHidden = true
            repsTextField.isHidden = false
        }
    }

    @objc private func didTapAddButton() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter the exercise name.")
            return
        }

        let calories = Double(caloriesTextField.text ?? "") ?? 0.0
        let type = typeSegmentedControl.titleForSegment(at: typeSegmentedControl.selectedSegmentIndex) ?? "Time"
        var duration: Double = 0.0
        var reps: Int64 = 0

        if type == "Time" {
            duration = Double(durationTextField.text ?? "") ?? 0.0
        } else {
            reps = Int64(repsTextField.text ?? "") ?? 0
        }

        let exerciseEntry = ExerciseEntryEntity(context: context)
        exerciseEntry.name = name
        exerciseEntry.calories = calories
        exerciseEntry.type = type
        exerciseEntry.duration = duration
        exerciseEntry.reps = reps
        exerciseEntry.date = selectedDate ?? Date()

        do {
            try context.save()
            onSave?()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save exercise entry: \(error)")
            showAlert(message: "Failed to save exercise entry.")
        }
    }

    private func resetFields() {
        nameTextField.text = ""
        caloriesTextField.text = ""
        durationTextField.text = ""
        repsTextField.text = ""
        typeSegmentedControl.selectedSegmentIndex = 0
        typeChanged()
    }

    // MARK: - Utility Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Dismiss keyboard when tapping outside of text fields
    private func addDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
