import Foundation

struct ActivityLog: Decodable {
    let id: Int
    let date: String
}

struct MemberProfile: Decodable {
    let lastActivityVisit: TimeInterval?
}

enum APIError: LocalizedError {
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .httpError(401):
            return "Invalid credentials. Check your username and App Password in Settings."
        case .httpError(let code):
            return "Server returned HTTP \(code)."
        }
    }
}

struct APIClient {
    private let base = "https://www.creativeapplications.net/wp-json"

    private func authHeader(username: String, password: String) -> String {
        let creds = "\(username):\(password)"
        return "Basic " + Data(creds.utf8).base64EncodedString()
    }

    func fetchLastActivityVisit(username: String, password: String) async throws -> TimeInterval {
        var req = URLRequest(url: URL(string: "\(base)/can/v1/member/\(username)")!)
        req.setValue(authHeader(username: username, password: password), forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw APIError.httpError(http.statusCode)
        }

        let profile = try JSONDecoder().decode(MemberProfile.self, from: data)
        return profile.lastActivityVisit ?? 0
    }

    func fetchActivityLogs(
        username: String,
        password: String,
        perPage: Int,
        silent: Bool
    ) async throws -> [ActivityLog] {
        var components = URLComponents(string: "\(base)/wp/v2/activity-logs")!
        var queryItems = [URLQueryItem(name: "per_page", value: "\(perPage)")]
        if silent {
            queryItems.append(URLQueryItem(name: "silent", value: "1"))
        }
        components.queryItems = queryItems

        var req = URLRequest(url: components.url!)
        req.setValue(authHeader(username: username, password: password), forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw APIError.httpError(http.statusCode)
        }

        return try JSONDecoder().decode([ActivityLog].self, from: data)
    }
}
