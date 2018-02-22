# Install a Python version via pyenv
#
# Usage:
#
#   python::version { '2.7.14': }
#
define python::version(
  $ensure  = 'installed',
  $env     = {},
  $version = $name,
) {
  require python
  require openssl

  $alias_hash = lookup('python::version::alias', Hash, 'deep', {})
  $dest = "/opt/python/${version}"

  if has_key($alias_hash, $version) {
    $to = $alias_hash[$version]

    python::alias { $version:
      ensure => $ensure,
      to     => $to,
    }
  } elsif $ensure == 'absent' {
    file { $dest:
      ensure => absent,
      force  => true,
    }
  } else {
    case $version {
      /jython/: { require java }
      default: { }
    }

    $default_env = {
      'CC'         => '/usr/bin/cc',
      'PYENV_ROOT' => $python::pyenv::prefix,
      'PYTHON_BUILD_CACHE_PATH' => "${python::prefix}/cache/pyenv",
    }

    if $::operatingsystem == 'Darwin' {
      include homebrew::config
      include boxen::config
      ensure_resource('package', 'readline')
    }

    $hierdata = lookup('python::version::env', Hash, 'deep', {})

    if has_key($hierdata, $::operatingsystem) {
      $os_env = $hierdata[$::operatingsystem]
    } else {
      $os_env = {}
    }

    if has_key($hierdata, $version) {
      $version_env = $hierdata[$version]
    } else {
      $version_env = {}
    }

    $_env = merge(merge(merge($default_env, $os_env), $version_env), $env)

    if has_key($_env, 'CC') and $_env['CC'] =~ /gcc/ {
      require gcc
    }

    exec { "python-install-${version}":
      command  => "pyenv install --skip-existing ${version}",
      cwd      => "${python::pyenv::prefix}/versions",
      provider => 'shell',
      timeout  => 0,
      creates  => $dest,
      user     => $python::pyenv::user,
      require  => [ Package['readline'], Package['openssl'] ],
      notify   => Exec["python-upgrade-pip-${version}"],
    }

    exec { "python-upgrade-pip-${version}":
      command     => 'pip install --upgrade pip',
      user        => $python::pyenv::user,
      path        => [
                      "${::boxen_home}/pyenv/versions/${version}/bin",
                      ],
      refreshonly => true,
    }

    Exec["python-install-${version}"] {
      environment +> sort(join_keys_to_values($_env, '='))
    }
  }
}
