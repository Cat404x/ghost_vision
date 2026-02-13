#!/usr/bin/env ruby

require 'open3'
require 'json'

# Ruby CLI Orchestrator for Ghost Vision
# Responsibilities:
# - Accept CLI arguments
# - Call Rust engine binary via Open3
# - Parse JSON returned by Rust engine
# - Map JSON states to readable output
# - Print results in a formatted table

class GhostVision
  ENGINE_PATH = File.expand_path('engine/target/release/ghost_vision_engine', __dir__)
  
  STATE_LABELS = {
    'confirmed' => 'CONFIRMED',
    'not_found' => 'NOT FOUND',
    'rate_limited' => 'RATE LIMITED',
    'blocked' => 'BLOCKED',
    'redirected' => 'REDIRECTED',
    'inconclusive' => 'INCONCLUSIVE',
    'error' => 'ERROR'
  }.freeze
  
  def initialize(platform, username, url)
    @platform = platform
    @username = username
    @url = url
  end
  
  def execute
    # Check if engine binary exists
    unless File.exist?(ENGINE_PATH)
      puts "Error: Rust engine binary not found at #{ENGINE_PATH}"
      puts "Please build the engine first: cd engine && cargo build --release"
      exit 1
    end
    
    # Call Rust engine via Open3
    stdout_str, stderr_str, status = Open3.capture3(
      ENGINE_PATH,
      @platform,
      @username,
      @url
    )
    
    # Check if command executed successfully
    unless status.success?
      puts "Error: Failed to execute Rust engine"
      puts "STDERR: #{stderr_str}" unless stderr_str.empty?
      exit 1
    end
    
    # Parse JSON response
    begin
      result = JSON.parse(stdout_str)
    rescue JSON::ParserError => e
      puts "Error: Failed to parse JSON response from engine"
      puts "Response: #{stdout_str}"
      exit 1
    end
    
    # Validate JSON structure
    unless result.is_a?(Hash) && result.key?('platform') && result.key?('state')
      puts "Error: Invalid JSON structure from engine"
      puts "Response: #{stdout_str}"
      exit 1
    end
    
    # Display results in formatted table
    display_result(result)
  end
  
  private
  
  def display_result(result)
    platform = result['platform']
    state = result['state']
    http_status = result['http_status']
    
    # Map state to readable label
    label = STATE_LABELS[state] || state.upcase
    
    # Calculate column widths
    platform_width = [platform.length, 10].max
    label_width = [label.length, 12].max
    status_width = 12
    
    # Print table
    puts
    puts "=" * (platform_width + label_width + status_width + 10)
    puts "| %-#{platform_width}s | %-#{label_width}s | %-#{status_width}s |" % ['Platform', 'Result', 'HTTP Status']
    puts "=" * (platform_width + label_width + status_width + 10)
    puts "| %-#{platform_width}s | %-#{label_width}s | %-#{status_width}s |" % [platform, label, http_status || 'N/A']
    puts "=" * (platform_width + label_width + status_width + 10)
    puts
  end
end

# Main execution
if __FILE__ == $0
  if ARGV.length != 3
    puts "Usage: #{$0} <platform> <username> <url>"
    puts
    puts "Example:"
    puts "  #{$0} GitHub octocat https://github.com/octocat"
    puts
    exit 1
  end
  
  platform = ARGV[0]
  username = ARGV[1]
  url = ARGV[2]
  
  orchestrator = GhostVision.new(platform, username, url)
  orchestrator.execute
end
