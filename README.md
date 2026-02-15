# Ghost Vision ◈

**Deterministic Username Surface Validator**

Ghost Vision is a tool designed with a strict Ruby and Rust hybrid architecture. It validates the presence of usernames on various platforms by evaluating HTTP status codes only, ensuring accuracy and determinism.

---

## Architecture Overview

### Ruby CLI Orchestrator (`ghost_vision.rb`):
- Accepts a username as a command-line argument.
- Responsible for invoking the Rust engine using Open3.
- Parses JSON responses returned by the Rust engine.
- Displays results in a formatted output.

### Rust Deterministic HTTP Engine (`engine/src/main.rs`):
- Accepts platform, username, and URL as CLI arguments.
- Makes HTTP GET requests and evaluates HTTP response status codes.
- Produces JSON responses strictly adhering to the contract.
- Does not parse HTML or perform regex-based detections.

---

## Output Example

```
GitHub      ✓ CONFIRMED      (200)
Instagram   ✗ NOT FOUND      (404)
Reddit      ! RATE LIMITED   (429)
```

---

## JSON Contract

The Rust engine outputs JSON strictly in the following format:

```
{
  "platform": "GitHub",
  "state": "confirmed",
  "http_status": 200
}
```

### Allowed States:
- confirmed
- not_found
- rate_limited
- blocked
- redirected
- inconclusive
- error

---

## Dependencies and Requirements

### Ruby Requirements
- `json`
- `open3`

### Rust Requirements
- `reqwest = "0.11"`
- `serde = "1.0"`
- `serde_json = "1.0"`

---

## Usage

1. Compile the Rust engine:
   ```bash
   cd engine
   cargo build --release
   ```

2. Run the Ruby script, providing a username as input:
   ```bash
   ruby ghost_vision.rb <username>
   ```

---

## Constraints

- Ruby is not allowed to perform HTTP requests or parsing logic.
- Rust is forbidden from inspecting HTML content, regex matching, or string inference.

---

## Philosophy

**Accuracy > Hype**  
**Structure > Guessing**  
**State Modeling > Pattern Matching**

Ghost Vision prioritizes deterministic state evaluation over heuristic pattern matching. By strictly evaluating HTTP status codes, we ensure that results are reproducible and reliable, avoiding false positives that arise from content scraping or regex-based detection.

---