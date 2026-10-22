import UIKit

final class ProductDetailViewController: UIViewController {
    private let product: Product
    private let imageView = UIImageView()
    private var imageTask: URLSessionDataTask?
    
    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(APIConstants.encoderErrorText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = APIConstants.productDetailsText
        view.backgroundColor = .systemBackground
        configureView()
    }
    
    deinit {
        imageTask?.cancel()
    }
    
    private func configureView() {
        let scrollView = UIScrollView()
        let contentView = UIView()
        [scrollView, contentView, imageView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor), scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor), contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor), contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemFill
        imageView.image = UIImage(systemName: "photo")
        contentView.addSubview(imageView)
        
        let title = label(product.title, style: .title2, weight: .bold)
        let category = label(product.category.uppercased(), style: .footnote, color: .systemBlue, weight: .semibold)
        let price = label(product.price.formatted(.currency(code: APIConstants.currencyType)), style: .title3, color: .systemGreen, weight: .bold)
        let description = label(product.description, style: .body, color: .secondaryLabel)
        description.numberOfLines = 0
        let details = detailText()
        let stack = UIStackView(arrangedSubviews: [category, title, price, separator(), sectionTitle(APIConstants.descriptionText), description, separator(), sectionTitle(APIConstants.detailsText), details])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor), imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.72),
            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24), stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20), stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
        
        if let url = product.imageURL { imageTask = ImageLoader.shared.load(url) { [weak self] image in self?.imageView.image = image ?? UIImage(systemName: "photo")
        }
        }
    }
    
    private func detailText() -> UILabel {
        var lines = [String]()
        if let brand = product.brand { lines.append("\(APIConstants.brandText) \(brand)") }
        if let stock = product.stock { lines.append("\(APIConstants.inStockText) \(stock)") }
        if let rating = product.rating {
            let rate = rating.rate.formatted(.number.precision(.fractionLength(1)))
            lines.append("\(APIConstants.ratingText) \(rate) / 5 (\(rating.count) \(APIConstants.reviewsText)")
        }
        product.specifications?.sorted { $0.key < $1.key }.forEach { lines.append("\($0.key.capitalized): \($0.value.displayValue)") }
        let result = label(lines.isEmpty ? APIConstants.noAdditionalDetailsAvailText : lines.joined(separator: "\n"), style: .body, color: .secondaryLabel)
        result.numberOfLines = 0
        return result
    }
    
    private func label(_ text: String, style: UIFont.TextStyle, color: UIColor = .label, weight: UIFont.Weight? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = weight.map { UIFont.preferredFont(forTextStyle: style).withWeight($0) } ?? .preferredFont(forTextStyle: style)
        label.textColor = color
        return label
    }
    
    private func sectionTitle(_ title: String) -> UILabel {
        label(title, style: .headline, weight: .semibold)
    }
    
    private func separator() -> UIView {
        let view = UIView(); view.backgroundColor = .separator
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont { UIFont.systemFont(ofSize: pointSize, weight: weight)
    }
}
