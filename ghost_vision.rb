#!/usr/bin/env ruby

# Ghost Vision CLI

class GhostVision
  def initialize
    @vision = []
  end

  def add_ghost(name)
    @vision << name
    puts "Ghost \"#{name}\" added to vision!"
  end

  def view_ghosts
    if @vision.empty?
      puts "No ghosts in vision."
    else
      puts "Current Ghosts in Vision:"
      @vision.each { |ghost| puts "- \"#{ghost}\"" }
    end
  end

  def remove_ghost(name)
    if @vision.delete(name)
      puts "Ghost \"#{name}\" removed from vision!"
    else
      puts "Ghost \"#{name}\" not found in vision."
    end
  end
end

# CLI Interface
if __FILE__ == $0
  ghost_vision = GhostVision.new

  loop do
    puts "Options: add, view, remove, exit"
    print "> "
    input = gets.chomp.split
    command = input[0]
    case command
    when "add"
      ghost_vision.add_ghost(input[1])
    when "view"
      ghost_vision.view_ghosts
    when "remove"
      ghost_vision.remove_ghost(input[1])
    when "exit"
      break
    else
      puts "Invalid command."
    end
  end
end
