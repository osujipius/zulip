class zulip::app_frontend {
  include zulip::rabbit
  include zulip::nginx
  include zulip::supervisor

  $web_packages = [ "memcached", "python-pylibmc", "python-tornado", "python-django",
                    "python-pygments", "python-flup", "python-psycopg2",
                    "yui-compressor", "python-django-auth-openid",
                    "python-django-statsd-mozilla", "python-dns",
                    "build-essential", "libssl-dev", "python-ujson",
                    "python-defusedxml", "python-twitter",
                    "python-twisted", "python-markdown",
                    "python-django-south", "python-mock", "python-pika",
                    "python-django-pipeline", "hunspell-en-us",
                    "python-django-bitfield", "python-embedly",
                    "python-postmonkey", "python-django-jstemplate",
                    "redis-server", "python-redis", "python-django-guardian",
                    "python-diff-match-patch", "python-sourcemap", "python-mandrill",
                    "python-sockjs-tornado", "python-apns-client", "python-imaging",
                    "nodejs"]
  define safepackage ( $ensure = present ) {
    if !defined(Package[$title]) {
      package { $title: ensure => $ensure }
    }
  }
  safepackage { $web_packages: ensure => "installed" }

  file { "/etc/nginx/zulip-include/":
    require => Package[nginx],
    recurse => true,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/nginx/zulip-include/",
    notify => Service["nginx"],
  }
  file { "/etc/memcached.conf":
    require => Package[memcached],
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/memcached.conf",
  }
  file { "/etc/supervisor/conf.d/zulip.conf":
    require => Package[supervisor],
    ensure => file,
    owner => "root",
    group => "root",
    mode => 644,
    source => "puppet:///modules/zulip/supervisor/conf.d/zulip.conf",
    notify => Service["supervisor"],
  }
  file { "/home/zulip/tornado":
    ensure => directory,
    owner => "zulip",
    group => "zulip",
    mode => 755,
  }
  file { "/etc/redis/redis.conf":
    require => Package[redis-server],
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/redis/redis.conf",
  }
  service { 'redis-server':
    ensure     => running,
    subscribe  => File['/etc/redis/redis.conf'],
  }
  service { 'memcached':
    ensure     => running,
    subscribe  => File['/etc/memcached.conf'],
  }
  file { '/home/zulip/logs':
    ensure => 'directory',
    owner  => 'zulip',
    group  => 'zulip',
  }
  file { '/home/zulip/deployments':
    ensure => 'directory',
    owner  => 'zulip',
    group  => 'zulip',
  }
}
