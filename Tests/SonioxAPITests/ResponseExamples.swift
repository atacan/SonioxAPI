import CoreFoundation
import Foundation
import HTTPTypes
import OpenAPIRuntime
import SonioxAPITypes

/// Copyable examples of exhaustive response handling and typed property access.
///
/// The writer can be replaced in offline tests; the live example prints to stdout.
struct ResponseExamples {
    private let write: (String) -> Void

    init(write: @escaping (String) -> Void = { print($0) }) {
        self.write = write
    }

    struct Failure: Error, CustomStringConvertible {
        let operation: String
        let statusCode: Int
        let message: String

        var description: String {
            "\(operation) returned HTTP \(statusCode): \(message)"
        }
    }

    func uploadedFile(from output: Operations.upload_file.Output) async throws -> Components.Schemas.File {
        switch output {
        case .created(let response):
            write("upload_file: Operations.upload_file.Output = .created (HTTP 201)")
            let value: Components.Schemas.File = try response.body.json
            printFile(value, path: "upload_file.created.body.json")
            return value
        case .badRequest(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "upload_file", caseName: "badRequest", statusCode: 400, error: error)
        case .unauthorized(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "upload_file", caseName: "unauthorized", statusCode: 401, error: error)
        case .tooManyRequests(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "upload_file", caseName: "tooManyRequests", statusCode: 429, error: error)
        case .internalServerError(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "upload_file", caseName: "internalServerError", statusCode: 500, error: error)
        case .undocumented(let statusCode, let payload):
            throw await undocumentedFailure(operation: "upload_file", statusCode: statusCode, payload: payload)
        }
    }

    func createdTranscription(from output: Operations.create_transcription.Output) async throws -> Components.Schemas.Transcription {
        switch output {
        case .created(let response):
            write("create_transcription: Operations.create_transcription.Output = .created (HTTP 201)")
            let value: Components.Schemas.Transcription = try response.body.json
            printTranscription(value, path: "create_transcription.created.body.json")
            return value
        case .badRequest(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "create_transcription", caseName: "badRequest", statusCode: 400, error: error)
        case .unauthorized(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "create_transcription", caseName: "unauthorized", statusCode: 401, error: error)
        case .code402(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "create_transcription", caseName: "code402", statusCode: 402, error: error)
        case .tooManyRequests(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "create_transcription", caseName: "tooManyRequests", statusCode: 429, error: error)
        case .internalServerError(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "create_transcription", caseName: "internalServerError", statusCode: 500, error: error)
        case .undocumented(let statusCode, let payload):
            throw await undocumentedFailure(operation: "create_transcription", statusCode: statusCode, payload: payload)
        }
    }

    func transcription(from output: Operations.get_transcription.Output) async throws -> Components.Schemas.Transcription {
        switch output {
        case .ok(let response):
            write("get_transcription: Operations.get_transcription.Output = .ok (HTTP 200)")
            let value: Components.Schemas.Transcription = try response.body.json
            printTranscription(value, path: "get_transcription.ok.body.json")
            return value
        case .unauthorized(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription", caseName: "unauthorized", statusCode: 401, error: error)
        case .notFound(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription", caseName: "notFound", statusCode: 404, error: error)
        case .tooManyRequests(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription", caseName: "tooManyRequests", statusCode: 429, error: error)
        case .internalServerError(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription", caseName: "internalServerError", statusCode: 500, error: error)
        case .undocumented(let statusCode, let payload):
            throw await undocumentedFailure(operation: "get_transcription", statusCode: statusCode, payload: payload)
        }
    }

    func transcript(from output: Operations.get_transcription_transcript.Output) async throws -> Components.Schemas.TranscriptionTranscript {
        switch output {
        case .ok(let response):
            write("get_transcription_transcript: Operations.get_transcription_transcript.Output = .ok (HTTP 200)")
            let value: Components.Schemas.TranscriptionTranscript = try response.body.json
            printTranscript(value, path: "get_transcription_transcript.ok.body.json")
            return value
        case .unauthorized(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription_transcript", caseName: "unauthorized", statusCode: 401, error: error)
        case .notFound(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription_transcript", caseName: "notFound", statusCode: 404, error: error)
        case .conflict(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription_transcript", caseName: "conflict", statusCode: 409, error: error)
        case .tooManyRequests(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription_transcript", caseName: "tooManyRequests", statusCode: 429, error: error)
        case .internalServerError(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "get_transcription_transcript", caseName: "internalServerError", statusCode: 500, error: error)
        case .undocumented(let statusCode, let payload):
            throw await undocumentedFailure(operation: "get_transcription_transcript", statusCode: statusCode, payload: payload)
        }
    }

    func deletedTranscription(from output: Operations.delete_transcription.Output) async throws {
        switch output {
        case .noContent(let response):
            write("delete_transcription: Operations.delete_transcription.Output = .noContent (HTTP 204)")
            property("delete_transcription.noContent", response)
        case .unauthorized(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_transcription", caseName: "unauthorized", statusCode: 401, error: error)
        case .notFound(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_transcription", caseName: "notFound", statusCode: 404, error: error)
        case .conflict(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_transcription", caseName: "conflict", statusCode: 409, error: error)
        case .tooManyRequests(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_transcription", caseName: "tooManyRequests", statusCode: 429, error: error)
        case .internalServerError(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_transcription", caseName: "internalServerError", statusCode: 500, error: error)
        case .undocumented(let statusCode, let payload):
            throw await undocumentedFailure(operation: "delete_transcription", statusCode: statusCode, payload: payload)
        }
    }

    func deletedFile(from output: Operations.delete_file.Output) async throws {
        switch output {
        case .noContent(let response):
            write("delete_file: Operations.delete_file.Output = .noContent (HTTP 204)")
            property("delete_file.noContent", response)
        case .unauthorized(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_file", caseName: "unauthorized", statusCode: 401, error: error)
        case .notFound(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_file", caseName: "notFound", statusCode: 404, error: error)
        case .tooManyRequests(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_file", caseName: "tooManyRequests", statusCode: 429, error: error)
        case .internalServerError(let response):
            let error: Components.Schemas.ApiError = try response.body.json
            throw apiFailure(operation: "delete_file", caseName: "internalServerError", statusCode: 500, error: error)
        case .undocumented(let statusCode, let payload):
            throw await undocumentedFailure(operation: "delete_file", statusCode: statusCode, payload: payload)
        }
    }

    func printFile(_ value: Components.Schemas.File, path: String) {
        let id: String = value.id
        let filename: String = value.filename
        let size: Int = value.size
        let createdAt: Date = value.created_at
        let clientReferenceId: String? = value.client_reference_id

        property("\(path).id", id)
        property("\(path).filename", filename)
        property("\(path).size", size)
        property("\(path).created_at", createdAt)
        property("\(path).client_reference_id", clientReferenceId)
    }

    func printTranscription(_ value: Components.Schemas.Transcription, path: String) {
        let id: String = value.id
        let status: Components.Schemas.TranscriptionStatus = value.status
        let createdAt: Date = value.created_at
        let model: String = value.model
        let audioUrl: String? = value.audio_url
        let fileId: String? = value.file_id
        let filename: String = value.filename
        let languageHints: [String]? = value.language_hints
        let enableSpeakerDiarization: Bool = value.enable_speaker_diarization
        let enableLanguageIdentification: Bool = value.enable_language_identification
        let audioDurationMs: Int? = value.audio_duration_ms
        let errorType: String? = value.error_type
        let errorMessage: String? = value.error_message
        let webhookUrl: String? = value.webhook_url
        let webhookAuthHeaderName: String? = value.webhook_auth_header_name
        let webhookAuthHeaderValue: String? = value.webhook_auth_header_value
        let webhookStatusCode: Int? = value.webhook_status_code
        let clientReferenceId: String? = value.client_reference_id

        property("\(path).id", id)
        property("\(path).status", status)
        property("\(path).created_at", createdAt)
        property("\(path).model", model)
        property("\(path).audio_url", audioUrl)
        property("\(path).file_id", fileId)
        property("\(path).filename", filename)
        property("\(path).language_hints", languageHints)
        property("\(path).enable_speaker_diarization", enableSpeakerDiarization)
        property("\(path).enable_language_identification", enableLanguageIdentification)
        property("\(path).audio_duration_ms", audioDurationMs)
        property("\(path).error_type", errorType)
        property("\(path).error_message", errorMessage)
        property("\(path).webhook_url", webhookUrl)
        property("\(path).webhook_auth_header_name", webhookAuthHeaderName)
        property("\(path).webhook_auth_header_value", webhookAuthHeaderValue)
        property("\(path).webhook_status_code", webhookStatusCode)
        property("\(path).client_reference_id", clientReferenceId)
        if let languageHints {
            for (index, language) in languageHints.enumerated() {
                property("\(path).language_hints[\(index)]", language)
            }
        }
    }

    func printToken(_ value: Components.Schemas.TranscriptionTranscriptToken, path: String) {
        let text: String = value.text
        let startMs: Int = value.start_ms
        let endMs: Int = value.end_ms
        let confidence: Double = value.confidence
        let speaker: String? = value.speaker
        let language: String? = value.language
        let isAudioEvent: Bool? = value.is_audio_event
        let translationStatus: String? = value.translation_status

        property("\(path).text", text)
        property("\(path).start_ms", startMs)
        property("\(path).end_ms", endMs)
        property("\(path).confidence", confidence)
        property("\(path).speaker", speaker)
        property("\(path).language", language)
        property("\(path).is_audio_event", isAudioEvent)
        property("\(path).translation_status", translationStatus)
    }

    func printValidationError(_ value: Components.Schemas.ApiErrorValidationError, path: String) {
        let errorType: String = value.error_type
        let location: String = value.location
        let message: String = value.message

        property("\(path).error_type", errorType)
        property("\(path).location", location)
        property("\(path).message", message)
    }

    func printTranscript(_ value: Components.Schemas.TranscriptionTranscript, path: String) {
        let id: String = value.id
        let text: String = value.text
        let tokens: [Components.Schemas.TranscriptionTranscriptToken] = value.tokens

        property("\(path).id", id)
        property("\(path).text", text)
        collection("\(path).tokens", tokens)
        // Print every token, including optional fields whose values are nil.
        for (index, token) in tokens.enumerated() {
            printToken(token, path: "\(path).tokens[\(index)]")
        }
    }

    func printAPIError(_ value: Components.Schemas.ApiError, path: String) {
        let statusCode: Int = value.status_code
        let errorType: String = value.error_type
        let message: String = value.message
        let validationErrors: [Components.Schemas.ApiErrorValidationError] = value.validation_errors
        let requestId: String = value.request_id
        let moreInfo: String? = value.more_info

        property("\(path).status_code", statusCode)
        property("\(path).error_type", errorType)
        property("\(path).message", message)
        collection("\(path).validation_errors", validationErrors)
        for (index, validationError) in validationErrors.enumerated() {
            printValidationError(validationError, path: "\(path).validation_errors[\(index)]")
        }
        property("\(path).request_id", requestId)
        property("\(path).more_info", moreInfo)
    }

    private func property<Value>(_ path: String, _ value: Value) {
        let rendered: String
        if let date = value as? Date {
            // Preserve the fractional seconds returned by Soniox.
            rendered = (try? ISO8601DateTranscoder.iso8601WithFractionalSeconds.encode(date)) ?? String(reflecting: date)
        } else {
            rendered = String(reflecting: value)
        }
        write("\(path): \(String(describing: Value.self)) = \(rendered)")
    }

    private func collection<Value>(_ path: String, _ values: [Value]) {
        write("\(path): \(String(describing: [Value].self)) = \(values.count) element(s)")
    }

    private func apiFailure(operation: String, caseName: String, statusCode: Int, error: Components.Schemas.ApiError) -> Failure {
        write("\(operation): Operations.\(operation).Output = .\(caseName) (HTTP \(statusCode))")
        printAPIError(error, path: "\(operation).\(caseName).body.json")
        return Failure(operation: operation, statusCode: statusCode, message: error.message)
    }

    private func undocumentedFailure(operation: String, statusCode: Int, payload: UndocumentedPayload) async -> Failure {
        let path = "\(operation).undocumented"
        write("\(operation): Operations.\(operation).Output = .undocumented")
        property("\(path).statusCode", statusCode)

        let headerFields: HTTPFields = payload.headerFields
        collection("\(path).headerFields", Array(headerFields))
        for (index, header) in headerFields.enumerated() {
            property("\(path).headerFields[\(index)].name", header.name)
            property("\(path).headerFields[\(index)].value", header.value)
        }

        let body: HTTPBody? = payload.body
        if let body {
            property("\(path).body.length", body.length)
            property("\(path).body.iterationBehavior", body.iterationBehavior)
            do {
                // An undocumented body is a stream: consume it once, before throwing.
                let data: Data = try await Data(collecting: body, upTo: .max)
                if let text: String = String(data: data, encoding: .utf8) {
                    property("\(path).body.text", text)
                } else {
                    property("\(path).body.base64", data.base64EncodedString())
                }
                if let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) {
                    printJSON(json, path: "\(path).body.json")
                }
            } catch {
                property("\(path).body.readError", String(describing: error))
            }
        } else {
            property("\(path).body", body)
        }
        return Failure(operation: operation, statusCode: statusCode, message: "Undocumented response; see the printed headers and body.")
    }

    // Undocumented JSON has no generated model. Walk all its properties with JSON types.
    private func printJSON(_ value: Any, path: String) {
        if let object = value as? [String: Any] {
            write("\(path): Dictionary<String, Any> = \(object.count) field(s)")
            for key in object.keys.sorted() {
                if let child = object[key] { printJSON(child, path: "\(path).\(key)") }
            }
        } else if let array = value as? [Any] {
            collection(path, array)
            for (index, child) in array.enumerated() { printJSON(child, path: "\(path)[\(index)]") }
        } else if value is NSNull {
            write("\(path): NSNull = null")
        } else if let string = value as? String {
            property(path, string)
        } else if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                property(path, number.boolValue)
            } else {
                property(path, number)
            }
        }
    }
}
