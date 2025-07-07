import UIKit

final class WordDetailsViewController: UIViewController {

    private let word: JishoWord

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - Init

    init(word: JishoWord) {
        self.word = word
        super.init(nibName: nil, bundle: nil)
        title = "Details"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        populateContent()
        setupNavigationBar()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(saveTapped)
        )
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func populateContent() {
        let kanji = word.japanese.first?.word ?? word.slug
        let reading = word.japanese.first?.reading ?? "—"

        addCenteredWordLabel(kanji) // 👉 слово теперь в центре и с большим шрифтом
        addLabel(title: "Reading", value: reading)

        if let jlpt = word.jlpt?.joined(separator: ", "), !jlpt.isEmpty {
            addLabel(title: "JLPT", value: jlpt)
        }

        var senseIndex = 1

        for sense in word.senses {
            if sense.partsOfSpeech.contains("Wikipedia definition") {
                if let wikiURL = sense.links?.first?.url {
                    let button = UIButton(type: .system)
                    button.setTitle("Open in Wikipedia", for: .normal)
                    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
                    button.addAction(UIAction { _ in
                        if let url = URL(string: wikiURL) {
                            UIApplication.shared.open(url)
                        }
                    }, for: .touchUpInside)

                    contentStack.addArrangedSubview(button)
                }
                continue
            }

            let defs = sense.englishDefinitions.joined(separator: ", ")
            let pos = sense.partsOfSpeech.joined(separator: ", ")

            addLabel(title: "Meaning \(senseIndex)", value: defs)
            if !pos.isEmpty {
                addLabel(title: "Part of Speech", value: pos)
            }
            senseIndex += 1
        }
    }

    private func addCenteredWordLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0

        contentStack.addArrangedSubview(label)
    }

    private func addLabel(title: String, value: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.numberOfLines = 0
        valueLabel.font = .systemFont(ofSize: 16)

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4

        contentStack.addArrangedSubview(stack)
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        let picker = CollectionPickerViewController()
        picker.onCollectionSelected = { [weak self] collection in
            guard let self = self else { return }
            CollectionsStorage.shared.addWord(self.word, to: collection.id)
            self.showToast(message: "Word saved to \"\(collection.title)\"")
        }
        present(UINavigationController(rootViewController: picker), animated: true)
    }
}
