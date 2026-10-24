// Generated from the final OpenAPI specification. Regenerated; do not edit.

internal enum OperationSecurity {
    enum Scheme: Sendable {
        case bearer
        case apiKey(header: String)
        case unsupported
    }

    static let schemes: [String: Scheme] = ["PublicApiAuth": .bearer]
    static let defaultRequirements: [[String]] = []
    static let operations: [String: [[String]]] = ["get_files": [["PublicApiAuth"]], "upload_file": [["PublicApiAuth"]], "get_files_count": [["PublicApiAuth"]], "get_file": [["PublicApiAuth"]], "delete_file": [["PublicApiAuth"]], "get_transcriptions": [["PublicApiAuth"]], "create_transcription": [["PublicApiAuth"]], "get_transcriptions_count": [["PublicApiAuth"]], "get_transcription": [["PublicApiAuth"]], "delete_transcription": [["PublicApiAuth"]], "get_transcription_transcript": [["PublicApiAuth"]], "get_voices": [["PublicApiAuth"]], "create_voice": [["PublicApiAuth"]], "get_voices_count": [["PublicApiAuth"]], "get_voice": [["PublicApiAuth"]], "delete_voice": [["PublicApiAuth"]], "recompute_voice": [["PublicApiAuth"]], "get_models": [["PublicApiAuth"]], "get_tts_models": [["PublicApiAuth"]], "get_shared_voices": [["PublicApiAuth"]], "generate_tts": [["PublicApiAuth"]], "create_temporary_api_key": [["PublicApiAuth"]], "get_usage_logs": [["PublicApiAuth"]], "get_usage_summary": [["PublicApiAuth"]], "get_concurrency_limits": [["PublicApiAuth"]], "get_concurrent_streams_history": [["PublicApiAuth"]]]
}
