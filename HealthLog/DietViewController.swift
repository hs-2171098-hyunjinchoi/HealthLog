//import UIKit
//import CoreData
//
//class DietViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    // MARK: - Properties
//    let nameTextField = UITextField()
//    let caloriesTextField = UITextField()
//    let addButton = UIButton(type: .system)
//    let imageView = UIImageView()
//    let placeholderLabel = UILabel() // Placeholder label to indicate image addition
//    var context: NSManagedObjectContext!
//    var selectedDate: Date? // 날짜를 선택할 수 있도록 변경
//    var onSave: (() -> Void)?
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    }
//    
//    // MARK: - Setup Methods
//    private func setupUI() {
//        view.backgroundColor = .white
//        title = "Diet Entry"
//        
//        // Name TextField
//        nameTextField.placeholder = "Enter food name"
//        nameTextField.borderStyle = .roundedRect
//        nameTextField.delegate = self
//        nameTextField.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(nameTextField)
//        
//        // Calories TextField
//        caloriesTextField.placeholder = "Enter calories"
//        caloriesTextField.borderStyle = .roundedRect
//        caloriesTextField.keyboardType = .numberPad
//        caloriesTextField.delegate = self
//        caloriesTextField.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(caloriesTextField)
//        
//        // Image View
//        imageView.backgroundColor = .lightGray
//        imageView.contentMode = .scaleAspectFit
//        imageView.isUserInteractionEnabled = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(imageView)
//        
//        // Placeholder Label
//        placeholderLabel.text = "Tap to add food image"
//        placeholderLabel.textColor = .white
//        placeholderLabel.textAlignment = .center
//        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
//        imageView.addSubview(placeholderLabel)
//        
//        // Add Button
//        addButton.setTitle("Add Entry", for: .normal)
//        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(addButton)
//        
//        // Constraints
//        NSLayoutConstraint.activate([
//            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            caloriesTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
//            caloriesTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            caloriesTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            imageView.topAnchor.constraint(equalTo: caloriesTextField.bottomAnchor, constant: 20),
//            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            imageView.heightAnchor.constraint(equalToConstant: 200),
//            
//            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
//            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
//            
//            addButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
//            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//        
//        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
//        imageView.addGestureRecognizer(imageTapGesture)
//    }
//    
//    @objc private func didTapAddButton() {
//        guard let name = nameTextField.text, !name.isEmpty else {
//            showAlert(message: "Please enter the food name.")
//            return
//        }
//        
//        let calories = Double(caloriesTextField.text ?? "") ?? 0.0
//        
//        let dietEntry = DietEntryEntity(context: context)
//        dietEntry.name = name
//        dietEntry.calories = calories
//        dietEntry.date = selectedDate ?? Date() // 현재 날짜 저장
//        
//        if let image = imageView.image, image != UIImage(named: "placeholder") {
//            dietEntry.image = image.pngData()
//        }
//        
//        do {
//            try context.save()
//            onSave?()
//            navigationController?.popViewController(animated: true)
//        } catch {
//            print("Failed to save diet entry: \(error)")
//            showAlert(message: "Failed to save diet entry.")
//        }
//    }
//    
//    @objc private func didTapImageView() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.sourceType = .photoLibrary
//        present(imagePickerController, animated: true, completion: nil)
//    }
//    
//    // MARK: - UIImagePickerControllerDelegate
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let selectedImage = info[.originalImage] as? UIImage {
//            imageView.image = selectedImage
//            placeholderLabel.isHidden = true
//        }
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    // MARK: - Utility Methods
//    private func showAlert(message: String) {
//        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
//    
//    // Dismiss keyboard when tapping outside of text fields
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//}

import UIKit
import CoreData

class DietViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    let foodNameTextField = UITextField() // 음식 이름만 입력받는 텍스트 필드
    let searchButton = UIButton(type: .system) // 검색 버튼
    let caloriesTextField = UITextField()
    let addButton = UIButton(type: .system)
    let imageView = UIImageView()
    let placeholderLabel = UILabel()
    
    let predictedCaloriesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0 // Allow multiple lines
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var context: NSManagedObjectContext!
    var selectedDate: Date? // 날짜를 선택할 수 있도록 변경
    var onSave: (() -> Void)?
    
    private var debounceTimer: Timer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Diet Entry"

        // Name TextField
        foodNameTextField.placeholder = "Enter food name"
        foodNameTextField.borderStyle = .roundedRect
        foodNameTextField.delegate = self
        foodNameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(foodNameTextField)

        // Search Button
        searchButton.setTitle("Search", for: .normal)
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchButton)

        // Calories TextField
        caloriesTextField.placeholder = "Enter calories"
        caloriesTextField.borderStyle = .roundedRect
        caloriesTextField.keyboardType = .numberPad
        caloriesTextField.delegate = self
        caloriesTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(caloriesTextField)

        // Image View
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // Placeholder Label
        placeholderLabel.text = "Tap to add food image"
        placeholderLabel.textColor = .white
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholderLabel)

        // Predicted Calories Label
        predictedCaloriesLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        predictedCaloriesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(predictedCaloriesLabel)

        // Add Button
        addButton.setTitle("Add Entry", for: .normal)
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        // Constraints
        NSLayoutConstraint.activate([
            foodNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            foodNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            searchButton.centerYAnchor.constraint(equalTo: foodNameTextField.centerYAnchor),
            searchButton.leadingAnchor.constraint(equalTo: foodNameTextField.trailingAnchor, constant: 10),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 80),

            caloriesTextField.topAnchor.constraint(equalTo: foodNameTextField.bottomAnchor, constant: 20),
            caloriesTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            caloriesTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            predictedCaloriesLabel.topAnchor.constraint(equalTo: caloriesTextField.bottomAnchor, constant: 20),
            predictedCaloriesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            predictedCaloriesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            imageView.topAnchor.constraint(equalTo: predictedCaloriesLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            placeholderLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            addButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(imageTapGesture)
    }

    @objc private func didTapSearchButton() {
        guard let foodName = foodNameTextField.text, !foodName.isEmpty else {
            showAlert(message: "Please enter the food name.")
            return
        }

        print("Food name to search: \(foodName)")

        // 먼저 한국어로 검색 시도
        EdamamAPI.fetchCalories(for: foodName) { [weak self] (calories: Double?, servingSize: String?) in
            DispatchQueue.main.async {
                if let calories = calories, let servingSize = servingSize {
                    print("Calories found without translation: \(calories) per \(servingSize)")
                    self?.predictedCaloriesLabel.text = "Predicted Calories: \(calories) per \(servingSize)"
                } else {
                    print("Calories not found without translation, trying translation")
                    // 번역 시도
                    TranslationAPI.translateToEnglish(text: foodName) { translatedText in
                        guard let translatedText = translatedText else {
                            DispatchQueue.main.async {
                                self?.predictedCaloriesLabel.text = "Predicted Calories: Not found"
                            }
                            return
                        }

                        print("Translated Food Name: \(translatedText)")

                        EdamamAPI.fetchCalories(for: translatedText) { (translatedCalories: Double?, translatedServingSize: String?) in
                            DispatchQueue.main.async {
                                if let translatedCalories = translatedCalories, let translatedServingSize = translatedServingSize {
                                    print("Calories found with translated text: \(translatedCalories) per \(translatedServingSize)")
                                    self?.predictedCaloriesLabel.text = "Predicted Calories: \(translatedCalories) per \(translatedServingSize)"
                                } else {
                                    print("Calories not found with translated text")
                                    self?.predictedCaloriesLabel.text = "Predicted Calories: Not found"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @objc private func didTapAddButton() {
        guard let foodName = foodNameTextField.text, !foodName.isEmpty else {
            showAlert(message: "Please enter the food name.")
            return
        }
        
        let calories = Double(caloriesTextField.text ?? "") ?? 0.0
        
        let dietEntry = DietEntryEntity(context: context)
        dietEntry.name = foodName
        dietEntry.calories = calories
        dietEntry.date = selectedDate ?? Date() // 현재 날짜 저장
        
        if let image = imageView.image, image != UIImage(named: "placeholder") {
            dietEntry.image = image.pngData()
        }
        
        do {
            try context.save()
            onSave?()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save diet entry: \(error)")
            showAlert(message: "Failed to save diet entry.")
        }
    }
    
    @objc private func didTapImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            placeholderLabel.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Utility Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Dismiss keyboard when tapping outside of text fields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
