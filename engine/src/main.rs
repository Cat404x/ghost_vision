use serde::Serialize;
use std::env;

#[derive(Serialize)]
struct Response {
    platform: String,
    state: String,
    http_status: u16,
}

fn map_state(status: u16) -> &'static str {
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
        let error_response = Response {
            platform: "Unknown".to_string(),
            state: "error".to_string(),
            http_status: 0,
        };
        println!("{}", serde_json::to_string(&error_response).unwrap());
        std::process::exit(1);
    }

    let platform = &args[1];
    // Username is passed by the CLI but not used here since the URL is already constructed
    let _username = &args[2];
    let url = &args[3];

    match reqwest::blocking::get(url) {
        Ok(response) => {
            let status = response.status().as_u16();
            let state = map_state(status);
            let result = Response {
                platform: platform.to_string(),
                state: state.to_string(),
                http_status: status,
            };
            println!("{}", serde_json::to_string(&result).unwrap());
        }
        Err(_) => {
            let error_response = Response {
                platform: platform.to_string(),
                state: "error".to_string(),
                http_status: 0,
            };
            println!("{}", serde_json::to_string(&error_response).unwrap());
        }
    }
}