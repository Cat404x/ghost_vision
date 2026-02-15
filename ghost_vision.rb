#!/usr/bin/env ruby

require 'json'
require 'open3'

# ASCII Art Banner
puts <<~BANNER
   ░██████╗  ░█████╗ ░██████╗████████╗
   ██╔════╝ ██╔══██╗██╔════╝╚══██╔══╝
   ██║  ███╗██║  ██║███████╗   ██║
   ██║   ██║██║  ██║╚════██║   ██║
   ╚██████╔╝╚█████╔╝███████║   ██║
    ╚═════╝  ╚════╝ ╚══════╝   ╚═╝
        G H O S T   V I S I O N  ◈
   Deterministic Surface Validator  ⟁
              cat404X
BANNER

# Status states mapping
STATES = {
  confirmed: "✓ CONFIRMED",
  not_found: "✗ NOT FOUND",
  rate_limited: "! RATE LIMITED",
  blocked: "⊘ BLOCKED",
  redirected: "↻ REDIRECTED",
  inconclusive: "? INCONCLUSIVE",
  error: "⚠ ERROR"
}

# Platform definitions
PLATFORMS = {
  "GitHub" => "https://github.com/%s",
  "Instagram" => "https://www.instagram.com/%s/",
  "Reddit" => "https://www.reddit.com/user/%s",
  "Twitter" => "https://twitter.com/%s",
  "Medium" => "https://medium.com/@%s"
}

# Check for username argument
if ARGV.empty?
  puts "Usage: ruby ghost_vision.rb <username>"
  exit 1
end

username = ARGV[0]
engine_path = "./engine/target/release/username_engine"

# Check if engine exists
unless File.exist?(engine_path)
  puts "Error: Rust engine not found at #{engine_path}"
  puts "Please build the engine first: cd engine && cargo build --release"
  exit 1
end

puts "\nValidating username: #{username}\n"
puts "=" * 50

# Query each platform
PLATFORMS.each do |platform, url_template|
  url = url_template % username
  
  # Invoke Rust engine
  stdout, stderr, status = Open3.capture3(engine_path, platform, username, url)
  
  if status.success? && !stdout.strip.empty?
    begin
      result = JSON.parse(stdout, symbolize_names: true)
      state_symbol = STATES[result[:state].to_sym] || "? UNKNOWN"
      printf "%-15s %-20s (%d)\n", result[:platform], state_symbol, result[:http_status]
    rescue JSON::ParserError => e
      puts "#{platform.ljust(15)} ⚠ ERROR          (JSON parse error)"
    end
  else
    puts "#{platform.ljust(15)} ⚠ ERROR          (Engine failed)"
  end
end

puts "=" * 50
