#!/usr/bin/env ruby
require 'json'
require 'open3'

# ASCII Banner
puts <<~BANNER
  ╔═══════════════════════════════════════╗
  ║                                       ║
  ║         👻 GHOST VISION 👻           ║
  ║   Deterministic Username Validator    ║
  ║                                       ║
  ╚═══════════════════════════════════════╝
BANNER

# STATES mapping for username resolution
STATES = {
  'confirmed' => '✓ CONFIRMED',
  'not_found' => '✗ NOT FOUND',
  'rate_limited' => '! RATE LIMITED',
  'blocked' => '⊗ BLOCKED',
  'redirected' => '↻ REDIRECTED',
  'inconclusive' => '? INCONCLUSIVE',
  'error' => '✖ ERROR'
}

# Platform URL templates
PLATFORMS = {
  'GitHub' => 'https://github.com/%s',
  'Instagram' => 'https://instagram.com/%s',
  'Reddit' => 'https://reddit.com/user/%s',
  'Twitter' => 'https://twitter.com/%s',
  'LinkedIn' => 'https://linkedin.com/in/%s'
}

# Check if username is provided
if ARGV.empty?
  puts "Usage: ruby ghost_vision.rb <username>"
  exit 1
end

username = ARGV[0]
engine_path = File.join(__dir__, 'engine', 'target', 'release', 'username_engine')

# Check if engine is compiled
unless File.exist?(engine_path)
  puts "Error: Rust engine not found. Please compile it first:"
  puts "  cd engine && cargo build --release"
  exit 1
end

puts "\nSearching for username: #{username}\n\n"

# Query each platform
PLATFORMS.each do |platform, url_template|
  url = url_template % username
  
  # Call Rust binary using Open3.capture3
  stdout, stderr, status = Open3.capture3(engine_path, platform, username, url)
  
  if status.success?
    begin
      result = JSON.parse(stdout)
      state = result['state']
      http_status = result['http_status']
      state_text = STATES[state] || '? UNKNOWN'
      
      printf "%-12s %s (%d)\n", platform, state_text.ljust(20), http_status
    rescue JSON::ParserError
      puts "#{platform}      ✖ ERROR (JSON Parse Error)"
    end
  else
    puts "#{platform}      ✖ ERROR (Engine Failed)"
  end
end

puts "\n"
