# == Class: tomcat::install::package
#
# This class installs tomcat from installation packages
#
class tomcat::install::package {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # install packages
  package { 'tomcat server':
    ensure => $::tomcat::package_ensure_real,
    name   => $::tomcat::package_name
  }

  # install admin webapps
  if $::tomcat::admin_webapps {
    package { 'tomcat admin webapps':
      ensure => $::tomcat::package_ensure_real,
      name   => $::tomcat::admin_webapps_package_name_real
    }
  }

  # install extras
  if $::tomcat::extras_enable_real and $::tomcat::extras_package_name {
    package { 'tomcat extras':
      ensure => $::tomcat::package_ensure_real,
      name   => $::tomcat::extras_package_name
    }
  }

  # fix broken bits in some tomcat init scripts
  if $::osfamily == 'RedHat' and $::operatingsystem != 'Fedora' and $::operatingsystemmajrelease < '7' { #fix 'status' command for instances
    file_line { 'fix broken tomcat init script':
      path     => "/etc/init.d/${::tomcat::service_name_real}",
      line     => "            pid=\"$(/usr/bin/pgrep -d , -u \${TOMCAT_USER} -G \${TOMCAT_USER} -f Dcatalina.base=\${CATALINA_BASE})\"",
      match    => 'pid=.*pgrep',
      multiple => true,
      require  => Package['tomcat server']
    }
  }
  elsif $::osfamily == 'Debian' and $::tomcat::maj_version > '6' { #support symlinking init script to create instances
    file_line { 'fix broken tomcat init script':
      path    => "/etc/init.d/${::tomcat::service_name_real}",
      line    => "NAME=\"$(basename \$0)\"",
      match   => "^NAME=.*\$",
      require => Package['tomcat server']
    }
  }
}
