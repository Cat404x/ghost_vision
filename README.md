# Ghost Vision

Ghost Vision is a two-layer username validation tool that checks the availability of usernames across different platforms.

## Architecture

The project follows a strict two-layer architecture:

### Layer 1: Ruby CLI Orchestrator (`ghost_vision.rb`)

The Ruby layer is responsible for:
- Accepting command-line arguments (platform, username, URL)
- Calling the Rust engine binary via Open3
- Parsing JSON responses from the Rust engine
- Mapping state values to human-readable output
- Displaying results in a formatted table

**Important**: The Ruby layer performs NO HTTP requests, HTML parsing, or direct state detection.

### Layer 2: Rust HTTP Engine (`engine/src/main.rs`)

The Rust layer is responsible for:
- Accepting 3 CLI arguments: platform, username, and URL
- Performing HTTP GET requests
- Examining HTTP status codes (body content is ignored)
- Mapping status codes to standardized states
- Outputting results as JSON

**HTTP Status Code Mapping**:
- `200` → `confirmed`
- `404` → `not_found`
- `429` → `rate_limited`
- `403` → `blocked`
- `300-399` → `redirected`
- `500-599` → `inconclusive`
- Other codes → `inconclusive`
- Network errors → `error`

**JSON Output Format**:
```json
{
  "platform": "string",
  "state": "string",
  "http_status": number | null
}
```

## Requirements

- Ruby >= 3.0
- Rust >= 1.70 (with Cargo)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Cat404x/ghost_vision.git
   cd ghost_vision
   ```

2. Build the Rust engine:
   ```bash
   cd engine
   cargo build --release
   cd ..
   ```

## Usage

Run the Ruby CLI orchestrator with three arguments:

```bash
ruby ghost_vision.rb <platform> <username> <url>
```

### Examples

Check a GitHub profile:
```bash
ruby ghost_vision.rb GitHub octocat https://github.com/octocat
```

Check an Instagram profile:
```bash
ruby ghost_vision.rb Instagram testuser https://www.instagram.com/testuser/
```

### Output

The tool displays results in a formatted table:

```
============================================
| Platform   | Result       | HTTP Status  |
============================================
| GitHub     | CONFIRMED    | 200          |
============================================
```

## Possible Results

- **CONFIRMED**: The username exists (HTTP 200)
- **NOT FOUND**: The username does not exist (HTTP 404)
- **RATE LIMITED**: Too many requests (HTTP 429)
- **BLOCKED**: Access denied (HTTP 403)
- **REDIRECTED**: URL redirects (HTTP 3xx)
- **INCONCLUSIVE**: Server error or unexpected status (HTTP 5xx or other)
- **ERROR**: Network or connection error

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---