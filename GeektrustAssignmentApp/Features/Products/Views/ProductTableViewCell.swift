import UIKit

final class ProductTableViewCell: UITableViewCell {
    static let reuseIdentifier = APIConstants.reuseIndentifier
    private let productImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let categoryLabel = UILabel()
    private let priceLabel = UILabel()
    private var imageTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        backgroundColor = .clear
        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError(APIConstants.encoderErrorText)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        productImageView.image = UIImage(systemName: "photo")
    }

    func configure(with product: Product) {
        
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        categoryLabel.text = product.category.uppercased()
        priceLabel.text = product.price.formatted(.currency(code: "USD"))
        productImageView.image = UIImage(systemName: "photo")
        
        guard let imageURL = product.imageURL else { return }
        
        imageTask = ImageLoader.shared.load(imageURL) { [weak self] image in
            self?.productImageView.image = image ?? UIImage(systemName: "photo")
        }
    }

    private func configureViews() {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6), card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])

        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.tintColor = .tertiaryLabel
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.backgroundColor = .tertiarySystemFill
        productImageView.layer.cornerRadius = 10
        card.addSubview(productImageView)

        [titleLabel, descriptionLabel, categoryLabel, priceLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 1
        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        categoryLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        categoryLabel.textColor = .systemBlue
        priceLabel.font = .preferredFont(forTextStyle: .headline)
        priceLabel.textColor = .systemGreen
        
        let metadata = UIStackView(arrangedSubviews: [categoryLabel, UIView(), priceLabel])
        metadata.axis = .horizontal
        let texts = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, metadata])
        texts.axis = .vertical
        texts.spacing = 4
        texts.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(texts)
        
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12), productImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 92), productImageView.heightAnchor.constraint(equalToConstant: 92),
            texts.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12), texts.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            texts.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }
}
