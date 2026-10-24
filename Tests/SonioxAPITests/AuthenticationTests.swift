import Foundation
import HTTPTypes
import OpenAPIRuntime
import SonioxAPI
import Testing

struct AuthenticationTests {
    @Test
    func sharedAuthenticationPreservesBearerHeader() async throws {
        let client = Client(
            serverURL: try #require(URL(string: "https://example.invalid")),
            transport: BearerCheckingTransport(),
            authentication: .bearer("fixture-token")
        )
        let response = try await client.delete_file(path: .init(file_id: "fixture-file"))
        _ = try response.noContent
    }
}

private struct BearerCheckingTransport: ClientTransport {
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        #expect(operationID == "delete_file")
        #expect(request.headerFields[.authorization] == "Bearer fixture-token")
        return (HTTPResponse(status: .noContent), nil)
    }
}
