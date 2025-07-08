import UIKit

final class CollectionsListViewController: UITableViewController {
    
    private var collections: [WordCollection] = []
    
    var onCollectionSelected: ((WordCollection) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Collections"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCollectionTapped)
        )
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 70
        reloadCollections()
    }
    
    private func reloadCollections() {
        collections = CollectionsStorage.shared.getAll()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCollections()
    }
    
    @objc private func addCollectionTapped() {
        let alert = UIAlertController(title: "Новая коллекция", message: "Введите название", preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Создать", style: .default) { _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            _ = CollectionsStorage.shared.createCollection(title: text)
            self.reloadCollections()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - TableView DataSource & Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let collection = collections[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = collection.title
        content.image = UIImage(systemName: "folder")
        content.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = content
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = collections[indexPath.row]
        
        if let onCollectionSelected = onCollectionSelected {
            onCollectionSelected(collection)
            navigationController?.popViewController(animated: true)
        } else {
            let detailsVC = CollectionDetailsViewController(collection: collection)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    // MARK: - Swipe to delete
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            let collection = self.collections[indexPath.row]
            CollectionsStorage.shared.deleteCollection(id: collection.id)
            self.collections.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
