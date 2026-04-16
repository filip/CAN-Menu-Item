import Foundation

struct ActivityLog: Decodable {
    let id: Int
    let dateGmt: String
}

struct MemberProfile: Decodable {
    let lastActivityVisit: TimeInterval?
    let newActivityCount: Int?
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

    private static let appUserAgent: String = {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = info?["CFBundleVersion"] as? String ?? "0"
        return "Activity OSX Menu Item/\(version) (\(build))"
    }()

    private func authHeader(username: String, password: String) -> String {
        let creds = "\(username):\(password)"
        return "Basic " + Data(creds.utf8).base64EncodedString()
    }

    func fetchMemberProfile(username: String, password: String) async throws -> MemberProfile {
        var req = URLRequest(url: URL(string: "\(base)/can/v1/member/\(username)")!)
        req.setValue(authHeader(username: username, password: password), forHTTPHeaderField: "Authorization")
        req.setValue(APIClient.appUserAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw APIError.httpError(http.statusCode)
        }

        return try JSONDecoder().decode(MemberProfile.self, from: data)
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
        req.setValue(APIClient.appUserAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw APIError.httpError(http.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([ActivityLog].self, from: data)
    }
}
