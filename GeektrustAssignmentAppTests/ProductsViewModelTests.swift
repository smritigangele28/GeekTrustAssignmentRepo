import XCTest
@testable import GeektrustAssignmentApp

@MainActor
final class ProductsViewModelTests: XCTestCase {
    
    func testInitialLoadPublishesProducts() async {
        let service = MockProductsService(results: [.success(ProductPage(products: [Product(id: 1), Product(id: 2)], nextPage: 1))])
        let viewModel = ProductsViewModel(service: service)
        let delegate = ViewModelDelegateSpy()
        let update = expectation(description: "Products are published")
        delegate.updateExpectation = update
        viewModel.delegate = delegate

        viewModel.loadInitialProducts()
        await fulfillment(of: [update], timeout: 1)

        XCTAssertEqual(viewModel.products.map(\.id), [1, 2])
        XCTAssertEqual(service.requestedPages, [APIConstants.defaultPage])
    }

    func testNextPageDoesNotAppendDuplicateProducts() async {
        let product = Product(id: 1)
        let service = MockProductsService(results: [
            .success(ProductPage(products: [product], nextPage: 1)),
            .success(ProductPage(products: [product], nextPage: 2))
        ])
        let viewModel = ProductsViewModel(service: service)
        let delegate = ViewModelDelegateSpy()
        viewModel.delegate = delegate

        let firstUpdate = expectation(description: "First page is published")
        delegate.updateExpectation = firstUpdate
        viewModel.loadInitialProducts()
        await fulfillment(of: [firstUpdate], timeout: 1)

        let secondUpdate = expectation(description: "Duplicate page is handled")
        delegate.updateExpectation = secondUpdate
        viewModel.loadNextPage()
        await fulfillment(of: [secondUpdate], timeout: 1)

        XCTAssertEqual(viewModel.products.map(\.id), [1])
        XCTAssertEqual(service.requestedPages, [APIConstants.defaultPage, 1])
    }

    func testOfflineFailureIsReportedToDelegate() async {
        let service = MockProductsService(results: [.failure(.offline)])
        let viewModel = ProductsViewModel(service: service)
        let delegate = ViewModelDelegateSpy()
        let error = expectation(description: "Offline error is reported")
        delegate.errorExpectation = error
        viewModel.delegate = delegate

        viewModel.loadInitialProducts()
        await fulfillment(of: [error], timeout: 1)

        XCTAssertTrue(delegate.didReceiveOfflineError)
    }
}

@MainActor
private final class MockProductsService: ProductsServicing {
    private var results: [Result<ProductPage, ProductsError>]
    private(set) var requestedPages: [Int] = []

    init(results: [Result<ProductPage, ProductsError>]) {
        self.results = results
    }

    func fetchProducts(page: Int) async throws -> ProductPage {
        requestedPages.append(page)
        guard !results.isEmpty else { throw ProductsError.unknown }
        return try results.removeFirst().get()
    }
}

@MainActor
private final class ViewModelDelegateSpy: ProductsViewModelDelegate {
    var updateExpectation: XCTestExpectation?
    var errorExpectation: XCTestExpectation?
    var didReceiveOfflineError = false

    func productsViewModelDidUpdate(_ viewModel: ProductsViewModel) {
        updateExpectation?.fulfill()
        updateExpectation = nil
    }

    func productsViewModel(_ viewModel: ProductsViewModel, didChangeLoadingState isLoading: Bool, isInitialLoad: Bool) {}

    func productsViewModel(_ viewModel: ProductsViewModel, didFailWith error: ProductsError) {
        if case .offline = error { didReceiveOfflineError = true }
        errorExpectation?.fulfill()
        errorExpectation = nil
    }

    func productsViewModelDidReceiveEmptyResult(_ viewModel: ProductsViewModel) {}
}
