use reqwest;
use serde::{Serialize};
use std::env;

#[derive(Serialize)]
struct Output {
    platform: String,
    state: String,
    http_status: u16,
}

fn map_state(status: u16) -> String {
    match status {
        200 => "confirmed".to_string(),
        404 => "not_found".to_string(),
        429 => "rate_limited".to_string(),
        403 => "blocked".to_string(),
        300..=399 => "redirected".to_string(),
        500..=599 => "inconclusive".to_string(),
        _ => "inconclusive".to_string(),
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    
    if args.len() != 4 {
        eprintln!("Usage: {} <platform> <username> <url>", args[0]);
        std::process::exit(1);
    }
    
    let platform = &args[1];
    let _username = &args[2];
    let url = &args[3];
    
    let output = match reqwest::blocking::get(url) {
        Ok(response) => {
            let status = response.status().as_u16();
            Output {
                platform: platform.to_string(),
                state: map_state(status),
                http_status: status,
            }
        }
        Err(_) => {
            Output {
                platform: platform.to_string(),
                state: "error".to_string(),
                http_status: 0,
            }
        }
    };
    
    println!("{}", serde_json::to_string(&output).expect("Failed to serialize output to JSON"));
}