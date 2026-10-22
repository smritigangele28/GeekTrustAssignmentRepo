import UIKit

/// Displays an electronics catalog and requests successive pages near the end.
final class ViewController: UIViewController {
    private let viewModel: ProductsViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let stateView = StateView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let footerLoadingView = UIActivityIndicatorView(style: .medium)

    init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(APIConstants.encoderErrorText)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = APIConstants.electronicsCategory.capitalized
        view.backgroundColor = .systemBackground
        configureTableView()
        configureStateView()
        configureLoadingView()
        viewModel.delegate = self
        viewModel.loadInitialProducts()
    }

    private func configureTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: ProductTableViewCell.reuseIdentifier)
        tableView.rowHeight = 136
        tableView.estimatedRowHeight = 136
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 52))
        footerLoadingView.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(footerLoadingView)
        
        NSLayoutConstraint.activate([
            footerLoadingView.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            footerLoadingView.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
        ])
        tableView.tableFooterView = footer
    }

    private func configureStateView() {
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.isHidden = true
        stateView.onRetry = { [weak self] in self?.viewModel.retry() }
        view.addSubview(stateView)
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension ViewController: ProductsViewModelDelegate {
    func productsViewModelDidUpdate(_ viewModel: ProductsViewModel) {
        tableView.reloadData()
        stateView.isHidden = true
    }

    func productsViewModel(_ viewModel: ProductsViewModel, didChangeLoadingState isLoading: Bool, isInitialLoad: Bool) {
        if isInitialLoad {
            isLoading ? loadingView.startAnimating() : loadingView.stopAnimating()
        }
        else {
            isLoading ? footerLoadingView.startAnimating() : footerLoadingView.stopAnimating()
        }
    }

    func productsViewModel(_ viewModel: ProductsViewModel, didFailWith error: ProductsError) {
        loadingView.stopAnimating()
        footerLoadingView.stopAnimating()
        guard viewModel.products.isEmpty else { showPaginationError(error)
            return
        }
        stateView.showError(title: error.title, message: error.message)
    }

    func productsViewModelDidReceiveEmptyResult(_ viewModel: ProductsViewModel) {
        loadingView.stopAnimating()
        stateView.showEmpty()
    }

    private func showPaginationError(_ error: ProductsError) {
        let alert = UIAlertController(title: APIConstants.paginationError, message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: APIConstants.retryText, style: .default) { [weak self] _ in self?.viewModel.loadNextPage() })
        alert.addAction(UIAlertAction(title: APIConstants.cancelText, style: .cancel))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.reuseIdentifier, for: indexPath) as! ProductTableViewCell
        cell.configure(with: viewModel.products[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(ProductDetailViewController(product: viewModel.products[indexPath.row]), animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= viewModel.products.count - 3 { viewModel.loadNextPage()
        }
    }
}
