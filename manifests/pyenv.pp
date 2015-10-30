# Manage python version with pyenv
#
# Usage:
#     include python::pyenv
#
# Normally internal use only; will automatically included by the `python` class
#
class python::pyenv(
  $ensure = $python::pyenv::ensure,
  $prefix = $python::pyenv::prefix,
  $user   = $python::pyenv::user,
) {
  require python

  if $::osfamily == 'Darwin' {
    require homebrew
    package { 'pyenv': }

    $require = Package['pyenv']

    file { "${prefix}/versions":
      ensure  => directory,
      owner   => $user,
      require => $require,
    }
  } else {
    repository { $prefix:
      ensure => $ensure,
      force  => true,
      source => 'yyuu/pyenv',
      user   => $user,
    }

    $require = Repository[$prefix]

    file { "${prefix}/versions":
      ensure  => symlink,
      force   => true,
      backup  => false,
      target  => '/opt/python',
      require => $require,
    }
  }

  file { $prefix:
    ensure  => directory,
    owner   => $user,
    require => $require,
  }

  file { "${python::prefix}/cache/pyenv":
    ensure  => directory,
    owner   => $user,
    require => $require,
  }
}
