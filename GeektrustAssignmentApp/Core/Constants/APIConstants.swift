import Foundation

enum APIConstants {
    static let productsBaseURL = "https://fakeapi.net/products"
    static let defaultPage = 0
    static let productsPerPage = 10
    static let electronicsCategory = "electronics"
    static let productDetailsText = "Product Details"
    static let encoderErrorText = "init(coder:) has not been implemented"
    static let noProductsErrorText = "No products found"
    static let messageLblText = "There are no electronics to show right now."
    static let untitledProduct = "Untitled product"
    static let noDiscriptionAvailable = "No description available."
    static let unrecognizedText = "Uncategorized"
    static let specificationValueText = "Expected a primitive specification value."
    static let reuseIndentifier = "ProductTableViewCell"
    static let paginationError = "Couldn’t load more products"
    static let retryText = "Retry"
    static let cancelText = "Cancel"
    static let descriptionText = "Description"
    static let detailsText = "Details"
    static let currencyType = "USD"
    static let noAdditionalDetailsAvailText = "No additional details available."
    static let ratingText = "Rating:"
    static let reviewsText = "reviews"
    static let inStockText = "In stock:"
    static let brandText = "Brand:"
    static let productServiceNotAvailText = "The product service is temporarily unavailable."
    

    enum QueryKey {
        static let page = "page"
        static let limit = "limit"
        static let category = "category"
    }
    
    enum NetworkError {
        static let offline = "Check your internet connection and try again."
        static let invalidRexponse = "The server returned an unexpected response."
        static let decodingError = "We couldn’t read the product data."
        static let unknownError = "Please try again in a moment."
        static let somethingWentWrong = "Something went wrong"
        static let offlineErrorStateText = "You’re offline"
    }
    
}
