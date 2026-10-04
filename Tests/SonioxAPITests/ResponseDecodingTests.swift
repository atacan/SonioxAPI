import Foundation
import HTTPTypes
import OpenAPIRuntime
import SonioxAPI
import SonioxAPITypes
import Testing

/// These tests use recorded JSON and an in-memory transport, so no API key is needed.
struct ResponseDecodingTests {
    @Test("Decode the recorded file upload response, including its fractional-second date")
    func decodeFileUploadFixture() async throws {
        let data = try fixture("files_response_sample")
        let client = try fixtureClient(statusCode: 201, data: data)
        var lines: [String] = []
        let examples = ResponseExamples(write: { lines.append($0) })

        let response = try await client.upload_file(body: uploadBody())
        let file: Components.Schemas.File = try await examples.uploadedFile(from: response)
        #expect(file.id == "bbed4495-1df7-4b8d-bd9c-7d50b12e064c")
        #expect(file.filename == "60s_speech.wav")
        #expect(file.size == 5_286_912)
        #expect(abs(file.created_at.timeIntervalSince1970 - 1_791_038_437.263) < 0.000_001)
        #expect(file.client_reference_id == nil)

        let path = "upload_file.created.body.json"
        try expectEveryJSONPropertyWasPrinted(data, at: path, lines: lines)
        #expect(lines.contains("\(path).created_at: Date = 2026-10-03T14:40:37.263Z"))
        #expect(lines.contains("\(path).client_reference_id: Optional<String> = nil"))
    }

    @Test("Decode the recorded transcript and print every property of all 178 tokens")
    func decodeTranscriptFixture() async throws {
        let data = try fixture("transcription_response_sample")
        let client = try fixtureClient(statusCode: 200, data: data)
        var lines: [String] = []
        let examples = ResponseExamples(write: { lines.append($0) })

        let response = try await client.get_transcription_transcript(path: .init(transcription_id: "fixture"))
        let transcript: Components.Schemas.TranscriptionTranscript = try await examples.transcript(from: response)
        #expect(transcript.id == "d75c100c-ebc9-4091-bd98-92be94fb81d5")
        #expect(transcript.text.hasPrefix("This is a test recording that will last only 60 seconds"))
        #expect(transcript.tokens.count == 178)
        #expect(transcript.tokens.map(\.text).joined() == transcript.text)

        let first = try #require(transcript.tokens.first)
        let last = try #require(transcript.tokens.last)
        #expect(first.text == "This")
        #expect(first.start_ms == 1_110)
        #expect(first.end_ms == 1_170)
        #expect(abs(first.confidence - 0.996_729_016_304_016_1) < 0.000_000_000_001)
        #expect(last.text == "ou.")
        #expect(last.start_ms == 59_490)
        #expect(last.end_ms == 59_550)
        for token in transcript.tokens {
            #expect(token.start_ms <= token.end_ms)
            #expect((0 ... 1).contains(token.confidence))
            #expect(token.speaker == nil)
            #expect(token.language == nil)
            #expect(token.is_audio_event == nil)
            #expect(token.translation_status == nil)
        }

        let path = "get_transcription_transcript.ok.body.json"
        try expectEveryJSONPropertyWasPrinted(data, at: path, lines: lines)
        #expect(lines.contains("\(path).tokens[0].confidence: Double = 0.9967290163040161"))
        #expect(lines.contains("\(path).tokens[177].speaker: Optional<String> = nil"))
    }

    @Test("Decode and print transcription metadata for every job status", arguments: Components.Schemas.TranscriptionStatus.allCases)
    func decodeTranscriptionMetadata(status: Components.Schemas.TranscriptionStatus) async throws {
        let expected = Components.Schemas.Transcription(
            id: "fixture-transcription",
            status: status,
            created_at: Date(timeIntervalSince1970: 1_791_038_437.263),
            model: "stt-async-v5",
            file_id: "fixture-file",
            filename: "60s_speech.wav",
            language_hints: ["en", "de"],
            enable_speaker_diarization: true,
            enable_language_identification: true,
            audio_duration_ms: status == .completed ? 60_000 : nil,
            error_type: status == .error ? "audio_invalid" : nil,
            error_message: status == .error ? "Invalid audio fixture" : nil,
            webhook_url: "https://example.com/webhook",
            webhook_auth_header_name: "Authorization",
            webhook_auth_header_value: "******************",
            webhook_status_code: status == .completed ? 200 : nil,
            client_reference_id: "fixture-reference"
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(ISO8601DateTranscoder.iso8601WithFractionalSeconds.encode(date))
        }
        let data = try encoder.encode(expected)
        var lines: [String] = []
        let examples = ResponseExamples(write: { lines.append($0) })

        let createClient = try fixtureClient(statusCode: 201, data: data)
        let createResponse = try await createClient.create_transcription(body: .json(.init(model: "stt-async-v5", file_id: "fixture-file")))
        let created = try await examples.createdTranscription(from: createResponse)
        #expect(created.id == expected.id)
        #expect(created.status == status)
        try expectEveryJSONPropertyWasPrinted(data, at: "create_transcription.created.body.json", lines: lines)

        let getClient = try fixtureClient(statusCode: 200, data: data)
        let getResponse = try await getClient.get_transcription(path: .init(transcription_id: expected.id))
        let actual = try await examples.transcription(from: getResponse)
        #expect(actual.status == status)
        #expect(actual.language_hints == ["en", "de"])
        #expect(actual.error_type == expected.error_type)
        #expect(actual.webhook_status_code == expected.webhook_status_code)
        try expectEveryJSONPropertyWasPrinted(data, at: "get_transcription.ok.body.json", lines: lines)
        #expect(lines.contains("get_transcription.ok.body.json.audio_url: Optional<String> = nil"))
    }

    @Test("Print non-nil optional token metadata, including false")
    func printOptionalTokenMetadata() {
        let token = Components.Schemas.TranscriptionTranscriptToken(
            text: "Hello",
            start_ms: 100,
            end_ms: 200,
            confidence: 0.95,
            speaker: "speaker-1",
            language: "en",
            is_audio_event: false,
            translation_status: "original"
        )
        var lines: [String] = []
        let examples = ResponseExamples(write: { lines.append($0) })
        examples.printToken(token, path: "token")
        #expect(lines.contains("token.speaker: Optional<String> = Optional(\"speaker-1\")"))
        #expect(lines.contains("token.language: Optional<String> = Optional(\"en\")"))
        #expect(lines.contains("token.is_audio_event: Optional<Bool> = Optional(false)"))
        #expect(lines.contains("token.translation_status: Optional<String> = Optional(\"original\")"))
    }

    struct FailureScenario: Sendable {
        let operation: String
        let caseName: String
        let statusCode: Int

        static let all: [FailureScenario] = [
            .init(operation: "upload_file", caseName: "badRequest", statusCode: 400),
            .init(operation: "upload_file", caseName: "unauthorized", statusCode: 401),
            .init(operation: "upload_file", caseName: "tooManyRequests", statusCode: 429),
            .init(operation: "upload_file", caseName: "internalServerError", statusCode: 500),
            .init(operation: "upload_file", caseName: "undocumented", statusCode: 599),
            .init(operation: "create_transcription", caseName: "badRequest", statusCode: 400),
            .init(operation: "create_transcription", caseName: "unauthorized", statusCode: 401),
            .init(operation: "create_transcription", caseName: "code402", statusCode: 402),
            .init(operation: "create_transcription", caseName: "tooManyRequests", statusCode: 429),
            .init(operation: "create_transcription", caseName: "internalServerError", statusCode: 500),
            .init(operation: "create_transcription", caseName: "undocumented", statusCode: 599),
            .init(operation: "get_transcription", caseName: "unauthorized", statusCode: 401),
            .init(operation: "get_transcription", caseName: "notFound", statusCode: 404),
            .init(operation: "get_transcription", caseName: "tooManyRequests", statusCode: 429),
            .init(operation: "get_transcription", caseName: "internalServerError", statusCode: 500),
            .init(operation: "get_transcription", caseName: "undocumented", statusCode: 599),
            .init(operation: "get_transcription_transcript", caseName: "unauthorized", statusCode: 401),
            .init(operation: "get_transcription_transcript", caseName: "notFound", statusCode: 404),
            .init(operation: "get_transcription_transcript", caseName: "conflict", statusCode: 409),
            .init(operation: "get_transcription_transcript", caseName: "tooManyRequests", statusCode: 429),
            .init(operation: "get_transcription_transcript", caseName: "internalServerError", statusCode: 500),
            .init(operation: "get_transcription_transcript", caseName: "undocumented", statusCode: 599),
            .init(operation: "delete_transcription", caseName: "unauthorized", statusCode: 401),
            .init(operation: "delete_transcription", caseName: "notFound", statusCode: 404),
            .init(operation: "delete_transcription", caseName: "conflict", statusCode: 409),
            .init(operation: "delete_transcription", caseName: "tooManyRequests", statusCode: 429),
            .init(operation: "delete_transcription", caseName: "internalServerError", statusCode: 500),
            .init(operation: "delete_transcription", caseName: "undocumented", statusCode: 599),
            .init(operation: "delete_file", caseName: "unauthorized", statusCode: 401),
            .init(operation: "delete_file", caseName: "notFound", statusCode: 404),
            .init(operation: "delete_file", caseName: "tooManyRequests", statusCode: 429),
            .init(operation: "delete_file", caseName: "internalServerError", statusCode: 500),
            .init(operation: "delete_file", caseName: "undocumented", statusCode: 599),
        ]
    }

    @Test("Decode and print every documented error case and undocumented responses", arguments: FailureScenario.all)
    func decodeFailureResponse(scenario: FailureScenario) async throws {
        let error = Components.Schemas.ApiError(
            status_code: scenario.statusCode,
            error_type: "invalid_request",
            message: "Example request failed",
            validation_errors: [.init(error_type: "missing", location: "body.model", message: "Field required")],
            request_id: "fixture-request",
            more_info: "https://soniox.com/docs/api-reference/errors"
        )
        let data = try JSONEncoder().encode(error)
        let client = try fixtureClient(statusCode: scenario.statusCode, data: data)
        var lines: [String] = []
        let examples = ResponseExamples(write: { lines.append($0) })

        do {
            switch scenario.operation {
            case "upload_file":
                let response = try await client.upload_file(body: uploadBody())
                _ = try await examples.uploadedFile(from: response)
            case "create_transcription":
                let response = try await client.create_transcription(body: .json(.init(model: "stt-async-v5", file_id: "fixture")))
                _ = try await examples.createdTranscription(from: response)
            case "get_transcription":
                let response = try await client.get_transcription(path: .init(transcription_id: "fixture"))
                _ = try await examples.transcription(from: response)
            case "get_transcription_transcript":
                let response = try await client.get_transcription_transcript(path: .init(transcription_id: "fixture"))
                _ = try await examples.transcript(from: response)
            case "delete_transcription":
                let response = try await client.delete_transcription(path: .init(transcription_id: "fixture"))
                try await examples.deletedTranscription(from: response)
            case "delete_file":
                let response = try await client.delete_file(path: .init(file_id: "fixture"))
                try await examples.deletedFile(from: response)
            default:
                Issue.record("Unknown fixture operation: \(scenario.operation)")
            }
            Issue.record("Expected an error response to throw.")
        } catch let failure as ResponseExamples.Failure {
            #expect(failure.operation == scenario.operation)
            #expect(failure.statusCode == scenario.statusCode)
            let path =
                scenario.caseName == "undocumented"
                ? "\(scenario.operation).undocumented.body.json"
                : "\(scenario.operation).\(scenario.caseName).body.json"
            try expectEveryJSONPropertyWasPrinted(data, at: path, lines: lines)
            if scenario.caseName == "undocumented" {
                #expect(lines.contains(where: { $0.contains(".headerFields[0].name:") }))
                #expect(lines.contains(where: { $0.contains(".body.text: String =") }))
            } else {
                #expect(failure.message == error.message)
                #expect(lines.contains("\(path).validation_errors[0].location: String = \"body.model\""))
            }
        }
    }

    @Test("Handle both successful cleanup responses")
    func decodeNoContentResponses() async throws {
        let client = try fixtureClient(statusCode: 204, data: nil)
        var lines: [String] = []
        let examples = ResponseExamples(write: { lines.append($0) })
        let transcriptionResponse = try await client.delete_transcription(path: .init(transcription_id: "fixture"))
        try await examples.deletedTranscription(from: transcriptionResponse)
        let fileResponse = try await client.delete_file(path: .init(file_id: "fixture"))
        try await examples.deletedFile(from: fileResponse)
        #expect(lines.contains(where: { $0.contains("delete_transcription") && $0.contains("HTTP 204") }))
        #expect(lines.contains(where: { $0.contains("delete_file") && $0.contains("HTTP 204") }))
    }

    @Test("Print undocumented text, binary, and absent bodies", arguments: ["text", "binary", "absent"])
    func printUndocumentedBody(kind: String) async throws {
        let data: Data? =
            switch kind {
            case "text": Data("Bad gateway".utf8)
            case "binary": Data([0, 255])
            default: nil
            }
        let client = try fixtureClient(statusCode: 599, data: data)
        var lines: [String] = []
        let examples = ResponseExamples(write: { lines.append($0) })
        let response = try await client.get_transcription(path: .init(transcription_id: "fixture"))
        do {
            _ = try await examples.transcription(from: response)
            Issue.record("Expected an undocumented response to throw.")
        } catch let failure as ResponseExamples.Failure {
            #expect(failure.statusCode == 599)
            switch kind {
            case "text":
                #expect(lines.contains("get_transcription.undocumented.body.text: String = \"Bad gateway\""))
            case "binary":
                #expect(lines.contains("get_transcription.undocumented.body.base64: String = \"AP8=\""))
            default:
                #expect(lines.contains("get_transcription.undocumented.body: Optional<HTTPBody> = nil"))
            }
        }
    }

    private func fixture(_ name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func fixtureClient(statusCode: Int, data: Data?) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
            transport: FixtureTransport(statusCode: statusCode, data: data)
        )
    }

    private func uploadBody() -> Operations.upload_file.Input.Body {
        .multipartForm([.file(.init(payload: .init(body: HTTPBody()), filename: "fixture.wav"))])
    }

    // Use the JSON itself to check field coverage, including every array element and null.
    private func expectEveryJSONPropertyWasPrinted(_ data: Data, at path: String, lines: [String]) throws {
        let json = try JSONSerialization.jsonObject(with: data)
        let expectedPaths = jsonPropertyPaths(json, at: path)
        let printedPaths = Set(lines.compactMap { $0.split(separator: ":", maxSplits: 1).first.map(String.init) })
        let missingPaths = expectedPaths.subtracting(printedPaths)
        #expect(missingPaths.isEmpty, "Properties missing from example output: \(missingPaths.sorted())")
    }

    private func jsonPropertyPaths(_ value: Any, at path: String) -> Set<String> {
        if let object = value as? [String: Any] {
            return object.reduce(into: Set<String>()) { paths, field in
                paths.formUnion(jsonPropertyPaths(field.value, at: "\(path).\(field.key)"))
            }
        }
        if let array = value as? [Any] {
            return array.enumerated()
                .reduce(into: Set([path])) { paths, item in
                    paths.formUnion(jsonPropertyPaths(item.element, at: "\(path)[\(item.offset)]"))
                }
        }
        return [path]
    }

    private struct FixtureTransport: ClientTransport {
        let statusCode: Int
        let data: Data?

        func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
            let response = HTTPResponse(
                status: .init(code: statusCode),
                headerFields: [.contentType: "application/json", .server: "fixture"]
            )
            return (response, data.map { HTTPBody($0) })
        }
    }
}
