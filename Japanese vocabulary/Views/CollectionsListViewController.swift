import UIKit

final class CollectionsListViewController: UITableViewController {
    
    private var collections: [WordCollection] = []
    
    // Колбек для передачи выбранной коллекции назад
    var onCollectionSelected: ((WordCollection) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Collections"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addCollectionTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            let newCollection = CollectionsStorage.shared.createCollection(title: text)
            self.reloadCollections()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - TableView DataSource & Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let collection = collections[indexPath.row]
        cell.textLabel?.text = collection.title
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
}
