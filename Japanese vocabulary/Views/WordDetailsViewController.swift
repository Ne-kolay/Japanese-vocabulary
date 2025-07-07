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

        addCenteredWordAndReading(word: kanji, reading: reading)

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

            let pos = sense.partsOfSpeech.joined(separator: ", ")
            let defs = sense.englishDefinitions.joined(separator: ", ")

            if !pos.isEmpty {
                addPlainLabel(pos)
            }

            addPlainLabel(defs)
        }

        if let jlpt = word.jlpt?.joined(separator: ", "), !jlpt.isEmpty {
            addPlainLabel(jlpt)
        }
    }

    private func addCenteredWordAndReading(word: String, reading: String) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4

        let wordLabel = UILabel()
        wordLabel.text = word
        wordLabel.font = .systemFont(ofSize: 48, weight: .bold)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0

        let readingLabel = UILabel()
        readingLabel.text = reading
        readingLabel.font = .systemFont(ofSize: 18)
        readingLabel.textAlignment = .center
        readingLabel.numberOfLines = 0
        readingLabel.textColor = .secondaryLabel

        stack.addArrangedSubview(wordLabel)
        stack.addArrangedSubview(readingLabel)

        contentStack.addArrangedSubview(stack)
    }

    private func addPlainLabel(_ value: String) {
        let label = UILabel()
        label.text = value
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        contentStack.addArrangedSubview(label)
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
