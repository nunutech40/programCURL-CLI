
import Foundation

enum HTTPMEthod: String {
    case get = "GET"
    case post = "POST"
}

class APINetwork {
    static let shared = APINetwork()
    
    private init() {}
    
    func request(urlString: String, method: HTTPMEthod, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, nil, NSError(domain: "Invalid URL", code: 400, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
    }
}