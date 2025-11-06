# MITM/Proxy Notes (Sanitized)
- Benign Host manipulation on safe path → deterministic 400 with stable length (~155 bytes). Useful for edge fingerprinting only.
- API endpoints: malformed encodings switched response from JSON→HTML. Saved anonymized headers/bodies in `artifacts/samples/`.
- REST gateway frequently returned placeholder JSON; GraphQL rejected invalid keys.
- TLS: `cacert.pem` required by client on startup; removal caused abort.
