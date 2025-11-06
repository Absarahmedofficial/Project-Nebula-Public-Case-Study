# Client/Binary Analysis
- PyInstaller/pyarmor bundle; Python libs + OpenSSL present.
- Verification routine calls into OpenSSL `EVP_DigestVerifyFinal`.
- Public key PEM markers exist in the binary image.
- Persistence observed: SQLite DB (no plain license), HKCU registry keys for UI state.
- Frida unreliable here; use x64dbg/IDA/ProcMon to map and observe.
