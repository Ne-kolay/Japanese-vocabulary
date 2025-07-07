//
//  CollectionPickerViewController.swift
//  Japanese vocabulary
//

import UIKit

/// Экран-лист для выбора (или создания) коллекции при сохранении слова.
final class CollectionPickerViewController: UITableViewController {

    /// Коллекции из хранилища
    private var collections: [WordCollection] = []

    /// Колбек, в который возвращаем выбранную коллекцию
    var onCollectionSelected: ((WordCollection) -> Void)?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Заголовок и «плюс»-кнопка
        navigationItem.title = "Сохранить в коллекцию"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCollectionTapped)
        )

        // Таблица
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()   // убираем лишние разделители
        reloadCollections()

        // Делаем лист
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]     // примерно ¾ и фулл
            sheet.prefersGrabberVisible = true        // «хваталка» сверху
        }
    }

    // MARK: - Private helpers
    private func reloadCollections() {
        collections = CollectionsStorage.shared.getAll()
        tableView.reloadData()
    }

    @objc private func addCollectionTapped() {
        let alert = UIAlertController(
            title: "Новая коллекция",
            message: "Введите название",
            preferredStyle: .alert
        )
        alert.addTextField { $0.placeholder = "Название" }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        alert.addAction(UIAlertAction(title: "Создать", style: .default) { _ in
            guard
                let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !text.isEmpty
            else { return }

            let newCollection = CollectionsStorage.shared.createCollection(title: text)
            self.onCollectionSelected?(newCollection)   // сразу отдаём
            self.dismiss(animated: true)
        })

        present(alert, animated: true)
    }

    // MARK: - Table view data source / delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collections.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = collections[indexPath.row].title
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let collection = collections[indexPath.row]
        onCollectionSelected?(collection)  // отдаём выбранную
        dismiss(animated: true)
    }
}
