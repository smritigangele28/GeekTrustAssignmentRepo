import UIKit

final class StateView: UIView {
    var onRetry: (() -> Void)?
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame); configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError(APIConstants.encoderErrorText)
    }

    func showError(title: String, message: String) {
        imageView.image = UIImage(systemName: "wifi.exclamationmark")
        titleLabel.text = title
        messageLabel.text = message
        retryButton.isHidden = false
        isHidden = false
    }

    func showEmpty() {
        imageView.image = UIImage(systemName: "shippingbox")
        titleLabel.text = APIConstants.noProductsErrorText
        messageLabel.text = APIConstants.messageLblText
        retryButton.isHidden = true
        isHidden = false
    }

    private func configure() {
        backgroundColor = .systemBackground
        imageView.tintColor = .secondaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 42, weight: .medium)
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textAlignment = .center
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        retryButton.configuration = .filled()
        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel, retryButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32), stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32), stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 56), messageLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor), messageLabel.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
        ])
    }

    @objc private func didTapRetry() { onRetry?() }
}
