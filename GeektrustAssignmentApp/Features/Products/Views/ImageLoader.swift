import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private init() {}

    @discardableResult
    func load(_ url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        if let cached = cache.object(forKey: url as NSURL) { completion(cached); return nil }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            let image = data.flatMap(UIImage.init(data:))
            if let image { self?.cache.setObject(image, forKey: url as NSURL) }
            DispatchQueue.main.async { completion(image) }
        }
        task.resume()
        return task
    }
}
