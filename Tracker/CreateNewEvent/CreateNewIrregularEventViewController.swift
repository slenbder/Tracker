//
//  CreateNewEventViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

// MARK: - CreateNewIrregularEventViewControllerDelegate

protocol CreateNewIrregularEventViewControllerDelegate: AnyObject {
    func didCreateNewEvent(_ tracker: Tracker, _ category: String)
}

// MARK: - CreateNewIrregularEventViewController

class CreateNewIrregularEventViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CreateNewIrregularEventViewControllerDelegate?
    weak var dismissDelegate: DismissProtocol?
    var trackerVC = TrackerViewController()
    
    private var selectedCategory : TrackerCategory?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var enteredTrackerName = ""
    
    let textField = UITextField()
    let stackView = UIStackView()
    let createButton = UIButton()
    let tableView = UITableView()
    let cancelButton = UIButton()
    
    let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let tableList = ["Категория"]
    let emojiList = ["😊", "😍", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🤖", "🤔", "🙏", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😴"]
    let colorList: [UIColor] = {
        var colors = [UIColor]()
        for i in 1...18 {
            if let color = UIColor(named: "CSelection\(i)") {
                colors.append(color)
            }
        }
        return colors
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новое нерегулярное событие"
        backGround()
        setupEventView()
        setupStackView()
        setupCancelButton()
        setupCreateButton()
        setupEmojiCollectionView()
        setupColorCollectionView()
        createTable()
        setupConstraint()
        setupScrollView()
    }
    
    // MARK: - Setup UI
    
    private func backGround() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupEventView() {
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.placeholder = "Введите название трекера"
        let paddingView : UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textField)
    }
    
    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }
    
    private func setupCreateButton() {
        createButton.setTitle("Создать", for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.isEnabled = false
        createButton.backgroundColor = .ypGray
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(createButton)
        
        createButton.addTarget(self, action: #selector(create), for: .touchUpInside)
    }
    
    private func setupEmojiCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        emojiCollectionView.collectionViewLayout = layout
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        
        contentView.addSubview(emojiCollectionView)
    }
    
    private func setupColorCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 6, bottom: 0, right: 5)
        
        colorCollectionView.collectionViewLayout = layout
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "colorCell")
        
        contentView.addSubview(colorCollectionView)
    }
    
    
    private func setupConstraint() {
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let colorLabel = UILabel()
        colorLabel.text = "Цвет"
        colorLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorLabel)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * tableList.count)),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 10),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: calculateCollectionViewHeight(for: emojiList.count, itemsPerRow: 6, itemHeight: 60)),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            colorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 10),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: calculateCollectionViewHeight(for: colorList.count, itemsPerRow: 6, itemHeight: 60)),
            
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 30),
            
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 30),
            
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func calculateCollectionViewHeight(for itemCount: Int, itemsPerRow: Int, itemHeight: CGFloat) -> CGFloat {
        let rows = ceil(Double(itemCount) / Double(itemsPerRow))
        return CGFloat(rows) * itemHeight
    }
    
    private func createTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 76
        tableView.backgroundColor = .ypBackground
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(tableView)
    }
    
    func checkCreateButtonValidation() {
        if selectedCategory != nil && !enteredTrackerName.isEmpty && selectedEmoji != nil && selectedColor != nil {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
            createButton.setTitleColor(.ypWhite, for: .normal)
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
            createButton.setTitleColor(.ypWhite, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @objc func cancel() {
        print("Cancel")
        dismiss(animated: true)
    }
    
    @objc func create(_ sender: UIButton) {
        print("Create")
        let newTracker = Tracker(id: UUID(),
                                 title: enteredTrackerName,
                                 color: selectedColor ?? .cSelection1,
                                 emoji: selectedEmoji ?? "🤔",
                                 schedule: [Weekday.monday,
                                            Weekday.tuesday,
                                            Weekday.wednesday,
                                            Weekday.thursday,
                                            Weekday.friday,
                                            Weekday.saturday,
                                            Weekday.sunday])
        
        self.trackerVC.createNewTracker(tracker: newTracker)
        self.delegate?.didCreateNewEvent(newTracker, selectedCategory?.title ?? "")
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CreateNewIrregularEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground
        cell.textLabel?.text = tableList[indexPath.row]
        cell.detailTextLabel?.text = selectedCategory?.title
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = tableList[indexPath.row]
        if selectedItem == "Категория" {
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = self
            let navigatonVC = UINavigationController(rootViewController: categoryViewController)
            present(navigatonVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension CreateNewIrregularEventViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiList.count
        } else {
            return colorList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let emojiLabel = UILabel()
            emojiLabel.text = emojiList[indexPath.row]
            emojiLabel.font = .systemFont(ofSize: 32)
            emojiLabel.textAlignment = .center
            cell.contentView.addSubview(emojiLabel)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            emojiLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
            emojiLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCell else {
                fatalError("Unexpected cell type")
            }
            let color = colorList[indexPath.row]
            cell.configure(with: color, isSelected: color == selectedColor)
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if selectedEmoji == emojiList[indexPath.row] {
                selectedEmoji = nil
            } else {
                selectedEmoji = emojiList[indexPath.row]
            }
            
            for cell in collectionView.visibleCells {
                cell.contentView.backgroundColor = .clear
            }
            if let cell = collectionView.cellForItem(at: indexPath), selectedEmoji != nil {
                cell.contentView.backgroundColor = .ypLightGray
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true
            }
        } else {
            let color = colorList[indexPath.row]
            selectedColor = (selectedColor == color) ? nil : color
            colorCollectionView.reloadData()
        }
        checkCreateButtonValidation()
    }
}

// MARK: - UITextFieldDelegate

extension CreateNewIrregularEventViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Название не может быть пустым"
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        enteredTrackerName = textField.text ?? ""
        checkCreateButtonValidation()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enteredTrackerName = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        checkCreateButtonValidation()
        return true
    }
}

// MARK: - CategoryViewControllerDelegate

extension CreateNewIrregularEventViewController: CategoryViewControllerDelegate {
    func categoryScreen(_ screen: CategoryViewController, didSelectedCategory category: TrackerCategory) {
        selectedCategory = category
        tableView.reloadData()
        checkCreateButtonValidation()
    }
}
