import Foundation
import HTTPTypes
import OpenAPIRuntime
import SonioxAPI
import SonioxAPIURLSession
import Testing

struct URLSessionFactoryDefaultsTests {
    @Test
    func decodesFractionalSecondDatesWithoutExplicitConfiguration() async throws {
        let client = Client.urlSession(
            serverURL: try #require(URL(string: "https://example.invalid")),
            middlewares: [FileFixtureMiddleware()]
        )
        let response = try await client.get_file(path: .init(file_id: "fixture-file"))
        let file = try response.ok.body.json
        #expect(file.id == "fixture-file")
        #expect(abs(file.created_at.timeIntervalSince1970 - 1_791_038_437.263) < 0.001)
    }

    @Test
    func respectsExplicitDateConfiguration() async throws {
        let client = Client.urlSession(
            serverURL: try #require(URL(string: "https://example.invalid")),
            configuration: .init(dateTranscoder: FixtureDateTranscoder()),
            middlewares: [FileFixtureMiddleware()]
        )
        let response = try await client.get_file(path: .init(file_id: "fixture-file"))
        #expect(try response.ok.body.json.created_at == Date(timeIntervalSince1970: 123))
    }

    @Test
    func evaluatesSharedBearerProviderBeforeTransport() async throws {
        // Throwing from the provider verifies authentication is installed and the
        // caller's credential is used, while preventing any network connection.
        let client = Client.urlSession(
            serverURL: try #require(URL(string: "https://example.invalid")),
            authentication: .bearer { throw FixtureAuthenticationError.providerEvaluated }
        )
        do {
            _ = try await client.get_file(path: .init(file_id: "fixture-file"))
            Issue.record("Expected the bearer provider to throw before transport")
        } catch let error as ClientError {
            #expect(error.underlyingError is FixtureAuthenticationError)
        }
    }

    @Test
    func rejectsMissingCredentialsBeforeTransport() async throws {
        let client = Client.urlSession(
            serverURL: try #require(URL(string: "https://example.invalid"))
        )
        do {
            _ = try await client.get_file(path: .init(file_id: "fixture-file"))
            Issue.record("Expected missing credentials to fail before transport")
        } catch let error as ClientError {
            guard case .unsatisfiedSecurityRequirements(let operationID) = error.underlyingError as? AuthenticationError else {
                Issue.record("Expected an unsatisfied security requirement")
                return
            }
            #expect(operationID == "get_file")
        }
    }
}

// Short-circuit before authentication/transport to exercise response conversion
// through each factory without contacting Soniox.
private struct FileFixtureMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        #expect(operationID == "get_file")
        let json = """
            {
                "id": "fixture-file",
                "filename": "60s_speech.wav",
                "size": 5286912,
                "created_at": "2026-10-03T14:40:37.263Z",
                "client_reference_id": null
            }
            """
        return (
            HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
            HTTPBody(Data(json.utf8))
        )
    }
}

private struct FixtureDateTranscoder: DateTranscoder {
    func encode(_ date: Date) throws -> String { "fixture-date" }
    func decode(_ value: String) throws -> Date { Date(timeIntervalSince1970: 123) }
}

private enum FixtureAuthenticationError: Error {
    case providerEvaluated
}
