import Foundation

protocol ProductsServicing {
    func fetchProducts(page: Int) async throws -> ProductPage
}

enum ProductsError: Error {
    case offline, invalidResponse, server(message: String), decoding, unknown

    var title: String {
        if case .offline = self {
            return APIConstants.NetworkError.offlineErrorStateText
        }
        
        return APIConstants.NetworkError.somethingWentWrong
    }
    
    var message: String {
        switch self {
        case .offline:
            return APIConstants.NetworkError.offline
        case .server(let message):
            return message
        case .invalidResponse:
            return APIConstants.NetworkError.invalidRexponse
        case .decoding:
            return APIConstants.NetworkError.decodingError
        case .unknown:
            return APIConstants.NetworkError.unknownError
        }
    }
}

final class ProductsService: ProductsServicing {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProducts(page: Int) async throws -> ProductPage {
        
        var components = URLComponents(string: APIConstants.productsBaseURL)!
        components.queryItems = [
            URLQueryItem(name: APIConstants.QueryKey.page, value: String(page)),
            URLQueryItem(name: APIConstants.QueryKey.limit, value: String(APIConstants.productsPerPage)),
            URLQueryItem(name: APIConstants.QueryKey.category, value: APIConstants.electronicsCategory)
        ]
        
        guard let url = components.url else {
            throw ProductsError.invalidResponse
        }

        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw ProductsError.server(message: APIConstants.productServiceNotAvailText)
            }
            do {
                return try JSONDecoder().decode(ProductPage.self, from: data)
            } catch {
                throw ProductsError.decoding
            }
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw ProductsError.offline
        } catch let error as ProductsError {
            throw error
        } catch {
            throw ProductsError.unknown
        }
    }
}
