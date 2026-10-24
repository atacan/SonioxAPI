We generate the Swift code using swift-openapi-generator. As we apply complex transformations to the original OpenAPI specification, we use a Python tool to do this. Run the generation with 

```bash
make regenerate
```

As this is a Swift package, you can find the code of the Swift package dependencies in the ".build/checkouts/" directory. Look at that folder when you need to understand how to use the code from the Swift package dependencies.


The package exposes Types, core Client/authentication, URLSession, and
AsyncHTTPClient products. Keep transport imports/dependencies in their wrapper
targets. Authentication lives in `Sources/SonioxAPI/Authentication`; the obsolete
Types middleware has been removed. Use `.bearer(apiKey)` for Soniox's
`PublicApiAuth` bearer scheme, even though the credential is called an API key.

Both transport factories default to
`Configuration(dateTranscoder: .iso8601WithFractionalSeconds)` because Soniox
returns dates such as `2026-10-03T14:40:37.263Z`. If response decoding fails with
`DecodingError.dataCorrupted` at a date field, check the date transcoder before
changing the schema. Raw `Client` initializers retain the runtime's default and
need explicit fractional-second configuration; factories accept caller overrides.
These helpers and this document are preserved on regeneration.

Use `swift test --filter 'ResponseDecodingTests|FactoryDefaultsTests|AuthenticationTests'` for offline
validation. The separate `transcribeSpeechFile` test reads the ignored `.env`
and performs live API calls when a key is available; run it only when requested.
