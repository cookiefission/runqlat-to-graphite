#!/usr/bin/env ruby

require 'socket'

HOST = Socket.gethostname
GRAPHITE_PUSH_ITERATIONS = 15
HISTOGRAM_LINE_REGEX = %r{
  \[ # Leading [
  (\d+) # Capture bucket lower bound
  (?:,\s*\d+)? # Optional match upper bound
  [\)\]]? # Closing brace
  \s* # Optional space
  (\d+) # Capture bucket value
}x

GRAPHITE_HOST = ENV.fetch('GRAPHITE_HOST', 'localhost')
BPF_LATENCY_SCRIPT = ENV.fetch('BPF_LATENCY_SCRIPT', '/root/cpu_latency.bt')

# Run bpftrace in background
io = IO.popen(
  "/usr/local/bin/bpftrace #{BPF_LATENCY_SCRIPT}"
)

graphite_socket = TCPSocket.new(GRAPHITE_HOST, 2003)

iterations = 0
aggregate = Hash.new(0)

loop do
  hist = io.gets("\n\n").chomp.split("\n")

  hist.each do |line|
    matched = line.match(HISTOGRAM_LINE_REGEX)

    next if matched.nil?

    bucket, value = matched.captures

    aggregate[bucket] += value.to_i
  end

  iterations += 1

  # Send data to Graphite every 15 iterations (approx every 15 seconds)
  if iterations == GRAPHITE_PUSH_ITERATIONS
    time = Time.now.to_i
    aggregate.each do |bucket, value|
      graphite_socket.puts("#{HOST}.cpu-lat.#{bucket} #{value} #{time}\n")
    end

    aggregate.clear
    iterations = 0
  end
end


