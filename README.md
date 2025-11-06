# Project Nebula — Redacted Case Study


Executive Summary

Project Nebula (redacted subscription/credits platform) was assessed under explicit authorization. We combined web/API testing and client/binary analysis to understand how licenses/credits are validated and where server‑side weaknesses might manifest.

Highlights

Edge exhibited Host header–driven behavior on a benign path; safely leveraged for fingerprinting only.

SSTI‑like indicators present on certain JSON endpoints (HTML error pages instead of JSON; stable length deltas) — useful for oracle‑style inference but no egress was possible.

Supabase backend observed; GraphQL strictly rejected invalid keys; public REST gateway frequently returned a stub response (sanitized here).

Client (Windows, PyInstaller/pyarmor) performs OpenSSL EVP signature verification with an embedded public key. Network tampering alone doesn’t bypass the gate.

Frida proved unstable; lab‑confirmed verification flow using x64dbg + IDA + ProcMon instead.

Legal & Ethics

All testing conducted with written permission; this case study is a sanitized learning artifact.

No secrets, service keys, or vendor binaries are published.

PoCs default to SAFE_MODE=1 and target dummy lab endpoints. Never run against systems you do not own or control.

Scope & Targets (Redacted)

Primary API (Edge): JSON endpoints similar to /api/v6/{check-license, insertkey, auth, users, profiles, transactions, licenses}.

Secondary host (pivot only): kept as a smuggling/bypass experiment path; not necessary for the public repo.

Supabase project: base URL identified (redacted); REST vs GraphQL behavior contrasts: REST often returned a stub JSON body; GraphQL returned Invalid API key for wrong/placeholder keys.

Desktop client: Windows executable (PyInstaller/pyarmor), includes Python stdlib and third‑party crypto modules; consult Client/Binary section.

Key Findings — Web/API

Host header behavior on safe path

Deterministic 400 with nearly fixed body length for crafted Host values on a benign endpoint; used for edge fingerprinting only.

SSTI indicators on API endpoints

Specific encodings (raw → %7B%7B → %257B variants) returned HTML error pages instead of JSON on two endpoints (redacted names), confirming template/rendering path traversal.

Consistent length deltas enabled stable diffing; egress was blocked (no OAST hits), so only timing/error‑based inference applicable.

Supabase behavior

REST gateway frequently responded with a stub JSON: { "msg": "Hello World" } to kept‑safe probes.

GraphQL endpoint (/graphql/v1) rejected placeholder/anon keys with Invalid API key (expected), confirming stricter enforcement.

Metadata SSRF attempts

Benign probes towards cloud metadata IP (169.254.169.254) via header manipulation were blocked at edge, returning a provider‑style block page.

Key Findings — Client/Binary (Windows)

Packaging: PyInstaller + pyarmor. The app bundles its Python code and crypto libs.

Crypto path: Python layer calls into native OpenSSL; observed strings and codepaths indicate EVP_DigestVerify* with final decision at EVP_DigestVerifyFinal.

Embedded public key: PEM markers present (public key / certificate block). Signature of server‑issued tokens is verified locally.

Persistence: SQLite DB present (e.g., Data.db / Data_backup_*.db). No explicit plain‑text license field found.

Registry: UI/telemetry keys under HKCU\Software\<VendorAlias>\… (e.g., display configs). Useful for filtering in ProcMon.

MITM constraints: cacert.pem required for startup; removing/tampering caused immediate abort.

Debugger strategy: Frida unstable on this target; switch to x64dbg for mapping: identify the indirect call to EVP_DigestVerifyFinal, observe EAX (1=valid, 0=invalid), and confirm UI transition logic depends on this gate. No bypass code is included in public repo; notes only.

Evidence & MITM/Proxy Reports (Sanitized)

Edge fingerprinting (safe)

# scripts/rest_probe.sh (SAFE_MODE)
# Expected: structured 400 with stable length on benign path for crafted Host
HTTP/2 400
content-type: text/html
<redacted body> # ~155 bytes (example)

API SSTI indicator (safe)

# Encodings: raw → %7B%7B → %257B
# Expected: switch from JSON to HTML error document; record lengths and status.
HTTP/2 403
content-type: text/html; charset=UTF-8
<html>… legacy conditional comments …</html>

REST gateway stub (safe)
GET /rest/v1/<table>?select=*
HTTP/2 200
{ "msg": "Hello World" }

GraphQL strictness (safe)
POST /graphql/v1 {"query":"{ __typename }"}
HTTP/2 401
{ "message": "Invalid API key", "hint": "Double check your Supabase key." }

Timing‑Oracle Research (Sanitized)

Concept: use error/timing deltas to test for character‑by‑character prefix extension of a protected secret (e.g., service key).

Observations: jitter requires averaging and heavier loop workload; consistent but weak signals were observed. Work halted for public release.

Repo provides research notes, not exploit code.

Defensive Recommendations

Enforce strict Host header handling (normalize/validate via trusted proxy headers only).

Ensure templating layers for API responses cannot be reached by untrusted input; prefer strict JSON serializers.

Continue to block egress from API tiers; consider canary outbound endpoints to audit attempted exfil.

For desktop clients, prefer short‑lived tokens or server‑side session checks; assume public keys and verification code are recoverable by users.

Monitor and rate‑limit unusual sequences that could be used to build timing oracles.

Methodology & Playbooks
Web/API

Recon: enumerate endpoints; capture baseline response shapes and lengths.

Probe: inject harmless encodings; compare JSON vs HTML response transitions.

Egress test: DNS/HTTP callbacks (expect to be blocked; record).

Logging: save headers and bodies per probe; compute size diffs.

Client/Binary (Windows)

Unpack PyInstaller bundle; catalog Python modules and crypto libs.

Search markers: EVP_DigestVerifyFinal, -----BEGIN, sqlite3, Data.db.

ProcMon filters: Process Name is the app; include RegCreateKey, RegSetValue, WriteFile; path contains Data.db.

x64dbg: identify indirect call to EVP_DigestVerifyFinal; watch EAX; confirm UI transition depends on return value.

Tools & Environment

HTTP tooling: curl, jq, Burp/mitmproxy (observation only)

Recon: ffuf, dirsearch, wayback tools (optional)

Debuggers: x64dbg, IDA, ProcMon; Frida explored but unstable

Scripts: small scanners (PEM/EVP markers), safe REST/GraphQL probes (with dummy hosts)




