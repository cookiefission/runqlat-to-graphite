class runqlat_to_graphite {
  file { '/root/cpu_latency.bt':
    ensure => present,
    path   => '/root/cpu_latency.bt',
    source => 'puppet:///modules/runqlat_to_graphite/cpu_latency.bt',
  }

  file { '/root/cpu_latency.rb':
    ensure => present,
    path   => '/root/cpu_latency.rb',
    mode   => '744',
    source => 'puppet:///modules/runqlat_to_graphite/cpu_latency.rb',
  }

  file { '/etc/systemd/system/cpu_latency.service':
    ensure => present,
    path   => '/etc/systemd/system/cpu_latency.service',
    source => 'puppet:///modules/runqlat_to_graphite/cpu_latency.service',
  }

  service { 'start cpu_latency service':
    name     => 'cpu_latency',
    ensure   => running,
    provider => 'systemd',
  }
}

