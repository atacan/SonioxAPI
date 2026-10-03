# SonioxAPI

Swift package generated from an OpenAPI specification. Run `make help` for build
and code-generation commands.

## Generation

Generated from [`original_openapi.yaml`](https://soniox.com/docs/openapi.yaml) using
[swift-openapi-bootstrapper](https://github.com/atacan/swift-package-generator-based-on-openapi)
version `0.3.0`, commit
[`5e9de08`](https://github.com/atacan/swift-package-generator-based-on-openapi/commit/5e9de08aed4353e6b39d9a1f8918f0a36f702e21)
(the latest `main` revision on October 3, 2026). Apple's Swift OpenAPI Generator
resolved to `1.13.1`; Swift dependencies are recorded in `Package.resolved`.

The package exports `SonioxAPI` for the client and `SonioxAPITypes` for models,
operation inputs and outputs, and `AuthenticationMiddleware(apiKey:)`.

To regenerate with the latest bootstrapper after replacing the original spec:

```bash
uvx --refresh --from git+https://github.com/atacan/swift-package-generator-based-on-openapi.git swift-bootstrapper bootstrap . --name SonioxAPI
```

Use `openapi-overlay.yaml` for manual schema corrections; `openapi.yaml` and
`Sources/*/GeneratedSources/` are generated files.

```bash
swift build
swift test
```

## Live speech-to-text test

`Tests/SonioxAPITests/SonioxAPITests.swift` follows the
[Soniox async transcription flow](https://soniox.com/docs/stt/async/async-transcription):
upload `60s_speech.wav` to `/v1/files`, create a `stt-async-v5` transcription at
`/v1/transcriptions`, poll `/v1/transcriptions/{transcription_id}`, then fetch
`/v1/transcriptions/{transcription_id}/transcript` and print the text. It verifies
that the transcript contains text and tokens.

Keep `60s_speech.wav` at the package root. Set `SONIOX_API_KEY` (or `API_KEY`) in
the environment, or copy `.env.example` to `.env` and replace its placeholder.
Both the audio file and `.env` are ignored by Git.

```bash
swift test --filter transcribeSpeechFile
```

The test skips when the API key is absent or still the placeholder. Providing a
key enables real API calls and transcription charges. Polling runs every two
seconds for up to three minutes, within a five-minute test limit. Completed or
failed jobs and their uploaded files are cleaned up; if polling stops before a
terminal status is known, the resources are retained and their IDs are printed.

### Inspect requests with mitmweb

Set `API_BASE_URL` in the environment or `.env` to override the generated Soniox
server URL. Environment values take precedence over `.env`; absent or empty
values use `https://api.soniox.com`.

Start a [reverse proxy](https://docs.mitmproxy.org/stable/concepts/modes/#reverse-proxy):

```bash
mitmweb \
  --mode reverse:https://api.soniox.com \
  --listen-host 127.0.0.1 \
  --listen-port 8080
```

Then run the test in another terminal, with the API key configured as above:

```bash
API_BASE_URL=http://127.0.0.1:8080 \
  swift test --filter transcribeSpeechFile
```

The generated endpoint paths already include `/v1`. A base URL ending in `/v2`
would produce paths such as `/v2/v1/transcriptions`, so use the proxy origin
unless the proxy explicitly rewrites that prefix.

## Secret scanning

This repository includes Betterleaks and TruffleHog checks based on
[this secret-scanning guide](https://actondon.com/blog/secret-scanning-for-git-repo).
Activate the local hooks after initializing or cloning the Git repository:

```bash
brew install pre-commit
pre-commit install
```

Alternatively, install pre-commit with `uv tool install pre-commit` or
`pip install pre-commit`. Version 3.2 or newer is required. pre-commit downloads
and builds the pinned scanners, bootstrapping Go if needed; its first run requires
network access and can take a few minutes. The bootstrapper generates the
configuration; each developer installs the hooks locally.

On a commit, Betterleaks scans the staged diff and redacts its findings. TruffleHog
scans the staged files supplied by pre-commit, which temporarily hides unstaged
edits. Both work before the first commit. TruffleHog checks candidate credentials
against provider APIs and blocks only verified, active secrets. Scanner execution
errors also fail the checks. Run `pre-commit run` to check staged changes manually.

The GitHub workflow runs on pushes and pull requests to every branch. It fetches
full history to determine ranges, but scans incoming commits: push before-to-after
and pull request merge-base-to-head. New branches are compared with the default
branch when available; an initial repository push scans its imported history.
Unchanged older history is outside subsequent CI scans. Both scanners run
independently, so findings from either cause a failed workflow.

OpenAPI specifications, overlays, examples, and generated Swift files are scanned.
Keep real credentials in environment variables and leave only placeholders in
examples. If a finding is a false positive, review the exact location before
adding a targeted exception:

- Betterleaks supports a `betterleaks:allow` comment on the relevant line or its reported
  fingerprint in a root `.betterleaksignore` file.
- TruffleHog supports a `trufflehog:ignore` comment on the relevant line.

For formats that cannot contain comments, use a scanner-specific configuration or
path exception limited to the affected fixture. Avoid excluding whole source or
specification directories. Rotate and revoke any exposed real credential.

Regenerating the package preserves existing hook configuration, workflow, and
documentation files, including your edits.
