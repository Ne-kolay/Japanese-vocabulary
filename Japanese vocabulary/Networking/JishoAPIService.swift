import Foundation

final class JishoAPIService {
    
    static let shared = JishoAPIService()
    private init() {}
    
    private let baseURL = "https://jisho.org/api/v1/search/words"

    func search(for keyword: String, completion: @escaping (Result<[JishoWord], Error>) -> Void) {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?keyword=\(encoded)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(JishoResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded.data))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }

    enum APIError: Error {
        case invalidURL
        case noData
    }
}
