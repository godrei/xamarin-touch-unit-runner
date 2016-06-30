require 'optparse'
require 'fileutils'
require 'tmpdir'

require_relative 'xamarin-builder/builder'

# -----------------------
# --- Functions
# -----------------------

def error_with_message(message)
  puts "\e[31m#{message}\e[0m"
end

# -----------------------
# --- Main
# -----------------------

#
# Parse options
options = {
  solution: nil,
  configuration: nil
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: step.rb [options]'
  opts.on('-s', '--solution path', 'Solution') { |s| options[:solution] = s unless s.to_s == '' }
  opts.on('-c', '--configuration config', 'Configuration') { |c| options[:configuration] = c unless c.to_s == '' }
  opts.on('-h', '--help', 'Displays Help') do
    exit
  end
end
parser.parse!

#
# Print options
puts
puts '========== Configs =========='
puts " * solution: #{options[:solution]}"
puts " * configuration: #{options[:configuration]}"

#
# Validate options
fail_with_message("No solution file found at path: #{options[:solution]}") unless options[:solution] && File.exist?(options[:solution])
fail_with_message('No configuration environment found') unless options[:configuration]

#
# Main
builder = Builder.new(options[:solution], options[:configuration], options[:platform], nil)
begin
  # The solution has to be built before runing the Touch.Unit tests
  builder.build_solution

  # Executing NUnit tests
  # TODO
rescue => ex
  error_with_message(ex.inspect.to_s)
  error_with_message('--- Stack trace: ---')
  error_with_message(ex.backtrace.to_s)
  exit(1)
end