use reqwest;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
struct ApiResponse {
    status: u16,
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
    let url = "http://example.com/api/status";
    match reqwest::blocking::get(url) {
        Ok(response) => {
            let status = response.status().as_u16();
            let state_message = map_state(status);
            println!("Status: {} - {}", status, state_message);
        }
        Err(_) => {
            println!("Error: network error");
        }
    }
}