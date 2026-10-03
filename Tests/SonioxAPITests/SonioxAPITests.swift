import Foundation
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import SonioxAPI
import SonioxAPITypes
import Testing
import UsefulThings

struct SonioxAPITests {
    private static let packageDirectory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    private static var apiKey: String? {
        let key = setting("SONIOX_API_KEY") ?? setting("API_KEY")
        guard let key, !key.isEmpty, key != "your_api_key_here" else { return nil }
        return key
    }

    // Read process environment first, then the ignored .env file at the package root.
    private static func setting(_ name: String) -> String? {
        if let value = ProcessInfo.processInfo.environment[name] {
            return value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let envURL = packageDirectory.appendingPathComponent(".env")
        guard let contents = try? String(contentsOf: envURL, encoding: .utf8) else { return nil }
        for line in contents.split(whereSeparator: \.isNewline) {
            let parts = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2,
                parts[0].trimmingCharacters(in: .whitespaces) == name
            else { continue }
            return parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        }
        return nil
    }

    @Test(
        "Transcribe 60s_speech.wav using the live Soniox API",
        .enabled(if: SonioxAPITests.apiKey != nil, "Set SONIOX_API_KEY or API_KEY in the environment or .env to run this live test."),
        .timeLimit(.minutes(5))
    )
    func transcribeSpeechFile() async throws {
        let apiKey = try #require(Self.apiKey)
        let audioURL = Self.packageDirectory.appendingPathComponent("60s_speech.wav")
        let fileHandle = try FileHandle(forReadingFrom: audioURL)
        defer { try? fileHandle.close() }

        let byteCount = try fileHandle.seekToEnd()
        try fileHandle.seek(toOffset: 0)
        try #require(byteCount > 0, "The audio file must contain data.")

        let serverURL: URL
        if let baseURL = Self.setting("API_BASE_URL"), !baseURL.isEmpty {
            serverURL = try #require(URL(string: baseURL), "API_BASE_URL must be a valid absolute HTTP or HTTPS URL.")
            try #require(
                ["http", "https"].contains(serverURL.scheme?.lowercased() ?? "") && serverURL.host?.isEmpty == false,
                "API_BASE_URL must be a valid absolute HTTP or HTTPS URL."
            )
        } else {
            serverURL = try Servers.Server1.url()
        }

        let client = Client(
            serverURL: serverURL,
            transport: AsyncHTTPClientTransport(),
            middlewares: [AuthenticationMiddleware(apiKey: apiKey)]
        )

        // UsefulThings makes FileHandle an AsyncSequence, so the WAV is streamed.
        let audioBody = HTTPBody(fileHandle, length: .known(Int64(byteCount)), iterationBehavior: .single)
        let uploadResponse = try await client.upload_file(
            body: .multipartForm([
                .file(.init(payload: .init(body: audioBody), filename: audioURL.lastPathComponent))
            ])
        )
        let uploadedFile = try uploadResponse.created.body.json
        print("Uploaded file: \(uploadedFile.id)")

        var transcriptionID: String?
        var reachedTerminalState = false

        do {
            let createResponse = try await client.create_transcription(
                body: .json(
                    .init(
                        model: "stt-async-v5",
                        file_id: uploadedFile.id
                    )
                )
            )
            let transcription = try createResponse.created.body.json
            transcriptionID = transcription.id
            print("Created transcription: \(transcription.id)")

            let finished = try await withPolling(
                configuration: .init(
                    maxAttempts: 90,
                    baseDelay: .seconds(2),
                    maxDelay: .seconds(2),
                    backoffMultiplier: 1,
                    jitterFactor: 0,
                    timeout: .seconds(180)
                ),
                until: { $0.status == .completed || $0.status == .error },
                operation: {
                    let response = try await client.get_transcription(path: .init(transcription_id: transcription.id))
                    let current = try response.ok.body.json
                    print("Transcription status: \(current.status.rawValue)")
                    return current
                }
            )
            reachedTerminalState = true
            try #require(
                finished.status == .completed,
                "Transcription failed: \(finished.error_type ?? "unknown"): \(finished.error_message ?? "No error message")"
            )
            #expect(finished.file_id == uploadedFile.id)

            let transcriptResponse = try await client.get_transcription_transcript(path: .init(transcription_id: transcription.id))
            let transcript = try transcriptResponse.ok.body.json
            #expect(transcript.id == transcription.id)
            #expect(!transcript.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!transcript.tokens.isEmpty)
            print("Transcript:\n\(transcript.text)")
        } catch {
            if let transcriptionID, reachedTerminalState {
                try? await Self.cleanUp(client: client, transcriptionID: transcriptionID, fileID: uploadedFile.id)
            } else if transcriptionID == nil {
                _ = try? await client.delete_file(path: .init(file_id: uploadedFile.id))
            } else {
                // Keep the file while the job may still be queued or processing.
                print("Polling stopped; retained transcription \(transcriptionID ?? "unknown") and file \(uploadedFile.id) for inspection.")
            }
            throw error
        }

        if let transcriptionID {
            try await Self.cleanUp(client: client, transcriptionID: transcriptionID, fileID: uploadedFile.id)
        }
    }

    private static func cleanUp(client: Client, transcriptionID: String, fileID: String) async throws {
        let transcriptionResponse = try await client.delete_transcription(path: .init(transcription_id: transcriptionID))
        _ = try transcriptionResponse.noContent
        let fileResponse = try await client.delete_file(path: .init(file_id: fileID))
        _ = try fileResponse.noContent
    }
}
