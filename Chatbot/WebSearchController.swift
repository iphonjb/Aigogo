import Foundation
class WebSearchController {
    enum SearchEngine { case opensearch, elasticsearch, duckduckgo }
    func search(query: String, completion: @escaping (String) -> Void) {
        let engine = selectEngine()
        let urlString: String
        switch engine {
        case .opensearch:
            urlString = ""http://localhost:9200/_search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? """")""
        case .elasticsearch:
            urlString = ""http://localhost:9200/_search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? """")""
        case .duckduckgo:
            urlString = ""https://api.duckduckgo.com/?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? """")&format=json""
        }
        guard let url = URL(string: urlString) else { completion(""); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { completion(""); return }
            completion(String(data: data, encoding: .utf8) ?? "")
        }.resume()
    }
    private func selectEngine() -> SearchEngine {
        return .opensearch
    }
}
