import Foundation
class WebSearchController {
    enum SearchEngine { case google, duckduckgo, naver }

    func search(query: String, completion: @escaping (String) -> Void) {
        let engine = selectEngine()
        let urlString: String

        switch engine {
        case .google:
            urlString = ""https://www.google.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? """")""
        case .duckduckgo:
            urlString = ""https://api.duckduckgo.com/?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? """")&format=json""
        case .naver:
            urlString = ""https://openapi.naver.com/v1/search/webkr.json?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? """")""
        }

        guard let url = URL(string: urlString) else { completion(""); return }
        var request = URLRequest(url: url)
        if engine == .naver {
            request.addValue(""<NAVER_CLIENT_ID>"", forHTTPHeaderField: ""X-Naver-Client-Id"")
            request.addValue(""<NAVER_CLIENT_SECRET>"", forHTTPHeaderField: ""X-Naver-Client-Secret"")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion(""); return }
            var resultText = ""
            switch engine {
            case .duckduckgo:
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let abstract = json["AbstractText"] as? String {
                    resultText = abstract
                }
            case .naver:
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let items = json["items"] as? [[String: Any]] {
                    resultText = items.prefix(3).compactMap { ["title"] as? String }.joined(separator: "\n")
                }
            default:
                resultText = String(data: data, encoding: .utf8) ?? ""
            }
            completion(resultText)
        }.resume()
    }

    private func selectEngine() -> SearchEngine {
        // 지역/환경 감지 후 엔진 자동 선택
        return .google
    }
}
