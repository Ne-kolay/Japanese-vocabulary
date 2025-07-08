import UIKit

final class CollectionDetailsViewController: UIViewController {

    private var collection: WordCollection
    private var words: [JishoWord] {
        collection.words
    }

    // MARK: - UI

    private let tableView = UITableView()

    // MARK: - Init

    init(collection: WordCollection) {
        self.collection = collection
        super.init(nibName: nil, bundle: nil)
        title = collection.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func deleteWord(at index: Int) {
        let wordToRemove = words[index]
        CollectionsStorage.shared.removeWord(wordToRemove, from: collection.id)

        // Обновляем коллекцию вручную
        if let updated = CollectionsStorage.shared.getById(collection.id) {
            self.collection.words = updated.words  // <- если можно напрямую менять
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension CollectionDetailsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        words.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = words[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let kanji = word.japanese.first?.word ?? word.slug
        let reading = word.japanese.first?.reading ?? "—"
        cell.textLabel?.text = "\(kanji) (\(reading))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CollectionDetailsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = words[indexPath.row]
        let vc = WordDetailsViewController(word: word)
        navigationController?.pushViewController(vc, animated: true)
    }

    // Свайп для удаления
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.deleteWord(at: indexPath.row)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
