import Foundation

struct Product: Decodable, Hashable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let brand: String?
    let stock: Int?
    let imageURL: URL?
    let specifications: [String: SpecificationValue]?
    let rating: Rating?

    enum CodingKeys: String, CodingKey {
        case id, title, price, description, category, brand, stock, image, specs, rating
    }

    init(
        id: Int,
        title: String = "Product",
        price: Double = 0,
        description: String = "Description",
        category: String = "electronics",
        brand: String? = nil,
        stock: Int? = nil,
        imageURL: URL? = nil,
        specifications: [String: SpecificationValue]? = nil,
        rating: Rating? = nil
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.brand = brand
        self.stock = stock
        self.imageURL = imageURL
        self.specifications = specifications
        self.rating = rating
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? APIConstants.untitledProduct
        price = try values.decodeIfPresent(Double.self, forKey: .price) ?? 0
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? APIConstants.noDiscriptionAvailable
        category = try values.decodeIfPresent(String.self, forKey: .category) ?? APIConstants.unrecognizedText
        brand = try values.decodeIfPresent(String.self, forKey: .brand)
        stock = try values.decodeIfPresent(Int.self, forKey: .stock)
        imageURL = try values.decodeIfPresent(URL.self, forKey: .image)
        specifications = try values.decodeIfPresent([String: SpecificationValue].self, forKey: .specs)
        rating = try values.decodeIfPresent(Rating.self, forKey: .rating)
    }
}

struct Rating: Decodable, Hashable { let rate: Double; let count: Int }

/// API specifications contain mixed primitive JSON values (for example, strings and booleans).
enum SpecificationValue: Decodable, Hashable {
    case string(String)
    case boolean(Bool)
    case integer(Int)
    case decimal(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) { self = .string(value) }
        else if let value = try? container.decode(Bool.self) { self = .boolean(value) }
        else if let value = try? container.decode(Int.self) { self = .integer(value) }
        else if let value = try? container.decode(Double.self) { self = .decimal(value) }
        else { throw DecodingError.typeMismatch(SpecificationValue.self, .init(codingPath: decoder.codingPath, debugDescription: APIConstants.specificationValueText)) }
    }

    var displayValue: String {
        switch self {
        case .string(let value): return value
        case .boolean(let value): return value ? "Yes" : "No"
        case .integer(let value): return String(value)
        case .decimal(let value): return value.formatted()
        }
    }
}

struct ProductPage: Decodable {
    let products: [Product]
    let nextPage: Int?

    init(products: [Product], nextPage: Int?) {
        self.products = products
        self.nextPage = nextPage
    }

    private enum CodingKeys: String, CodingKey { case data, products, nextPage, pagination }
    private enum PaginationKeys: String, CodingKey { case page, total, limit, nextPage }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        products = try container.decodeIfPresent([Product].self, forKey: .data)
            ?? container.decodeIfPresent([Product].self, forKey: .products) ?? []
        
        if let page = try container.decodeIfPresent(Int.self, forKey: .nextPage) {
            nextPage = page
        } else if let pagination = try? container.nestedContainer(keyedBy: PaginationKeys.self, forKey: .pagination),
                  let current = try pagination.decodeIfPresent(Int.self, forKey: .page),
                  let total = try pagination.decodeIfPresent(Int.self, forKey: .total),
                  let limit = try pagination.decodeIfPresent(Int.self, forKey: .limit),
                  (current + 1) * limit < total {
            nextPage = current + 1
        } else {
            nextPage = nil
        }
    }
}
