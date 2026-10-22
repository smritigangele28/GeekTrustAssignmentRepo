import Foundation

protocol ProductsViewModelDelegate: AnyObject {
    func productsViewModelDidUpdate(_ viewModel: ProductsViewModel)
    func productsViewModel(_ viewModel: ProductsViewModel, didChangeLoadingState isLoading: Bool, isInitialLoad: Bool)
    func productsViewModel(_ viewModel: ProductsViewModel, didFailWith error: ProductsError)
    func productsViewModelDidReceiveEmptyResult(_ viewModel: ProductsViewModel)
}

@MainActor
final class ProductsViewModel {
    weak var delegate: ProductsViewModelDelegate?
    private let service: ProductsServicing
    private(set) var products: [Product] = []
    private var nextPage: Int? = APIConstants.defaultPage
    private var isLoading = false

    init(service: ProductsServicing) {
        self.service = service
    }

    func loadInitialProducts() {
        products.removeAll()
        nextPage = APIConstants.defaultPage
        Task { [weak self] in
            await self?.load(page: APIConstants.defaultPage, isInitialLoad: true)
        }
    }

    func loadNextPage() {
        guard let nextPage, !isLoading else { return }
        Task { [weak self] in
            await self?.load(page: nextPage, isInitialLoad: false)
        }
    }
    
    func retry() {
        products.isEmpty ? loadInitialProducts() : loadNextPage()
    }

    private func load(page: Int, isInitialLoad: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        delegate?.productsViewModel(self, didChangeLoadingState: true, isInitialLoad: isInitialLoad)

        defer {
            isLoading = false
            delegate?.productsViewModel(self, didChangeLoadingState: false, isInitialLoad: isInitialLoad)
        }

        do {
            let productPage = try await service.fetchProducts(page: page)
            var seenProductIDs = Set(products.map(\.id))
            let newProducts = productPage.products.filter { seenProductIDs.insert($0.id).inserted }
            products.append(contentsOf: newProducts)
            nextPage = newProducts.isEmpty ? nil : productPage.nextPage
            products.isEmpty ? delegate?.productsViewModelDidReceiveEmptyResult(self) : delegate?.productsViewModelDidUpdate(self)
        } catch let error as ProductsError {
            delegate?.productsViewModel(self, didFailWith: error)
        } catch {
            delegate?.productsViewModel(self, didFailWith: .unknown)
        }
    }
}
