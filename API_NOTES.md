# API Findings (Redacted)
- Enumerated endpoints resembling `/api/v6/<name>`.
- Differential behavior per encoding strategy (raw/%7B%7B/%257B) observed.
- Metadata SSRF probes blocked at edge (`169.254.169.254`).
