# CPU run queue latency to Graphite

This is a script to ship CPU queue latency stats to Graphite every 15 seconds.

## System Requirements

- Ruby
- bpftrace
- systemd (preferred method for running it)
- puppet (preferred method for installing it)

## Getting it running

I prefer to use a systemd unit to keep the script running on the server.

- Copy `files/cpu_latency.service` from this repository to
  `/etc/systemd/system/cpu_latency.service` on the target server
- Start the service with `systemctl start cpu_latency`

## Installing with Puppet

This repository is a valid puppet module.

### Basic usage (masterless)

- Clone this repository to `/root/modules/runqlat_to_graphite`
- Apply with `puppet apply --modulepath=/root/modules/ -e "include runqlat_to_graphite"`

### 'Proper' usage

For longer-term usage, you will probably want to have a Puppet master server set
up and pull this module with r10k by specifiying it in your Puppetfile. I'll
leave that as an exercise for the reader.
