require 'socket'
HOST = Socket.gethostname

HISTOGRAM_LINE_REGEX = %r{
  \[ # Leading [
  (\d+) # Capture bucket lower bound
  (?:,\s*\d+)? # Optional match upper bound
  [\)\]]? # Closing brace
  \s* # Optional space
  (\d+) # Capture bucket value
}x

io = IO.popen(
  '/usr/bin/ssh root@54.154.141.130 -i /Users/sean/.ssh/freeagent -- ' +
  '/usr/local/bin/bpftrace /root/cpu_latency.bt',
)


graphite_socket = TCPSocket.new('localhost', 2003)
count = 0

aggregate = Hash.new(0)

loop do
  hist = io.gets("\n\n").chomp.split("\n")

  hist.each do |line|
    matched = line.match(HISTOGRAM_LINE_REGEX)

    next if matched.nil?

    bucket, value = matched.captures

    aggregate[bucket] += value.to_i
  end

  count += 1

  if count == 14
    time = Time.now.to_i
    aggregate.each do |bucket, value|
      graphite_socket.puts("#{HOST}.cpu-lat.#{bucket} #{value} #{time}\n")
    end

    aggregate.clear
    count = 0
  end
end


