use serde::Serialize;
use std::env;
use std::process;

#[derive(Serialize)]
struct EngineResponse {
    platform: String,
    state: String,
    http_status: Option<u16>,
}

fn map_status_to_state(status: u16) -> &'static str {
    match status {
        200 => "confirmed",
        404 => "not_found",
        429 => "rate_limited",
        403 => "blocked",
        300..=399 => "redirected",
        500..=599 => "inconclusive",
        _ => "inconclusive",
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 4 {
        eprintln!("Usage: {} <platform> <username> <url>", args[0]);
        process::exit(1);
    }

    let platform = &args[1];
    let _username = &args[2];
    let url = &args[3];

    let response = match reqwest::blocking::get(url) {
        Ok(resp) => {
            let status = resp.status().as_u16();
            let state = map_status_to_state(status);
            EngineResponse {
                platform: platform.to_string(),
                state: state.to_string(),
                http_status: Some(status),
            }
        }
        Err(_) => EngineResponse {
            platform: platform.to_string(),
            state: "error".to_string(),
            http_status: None,
        },
    };

    match serde_json::to_string(&response) {
        Ok(json) => println!("{}", json),
        Err(e) => {
            eprintln!("Failed to serialize response: {}", e);
            process::exit(1);
        }
    }
}