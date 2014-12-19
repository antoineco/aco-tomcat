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
    ensure => present,
    name   => $::tomcat::package_name
  }

  # install admin webapps
  if $::tomcat::admin_webapps {
    package { 'tomcat admin webapps':
      ensure => present,
      name   => $::tomcat::admin_webapps_package_name_real
    }
  }

  # fix broken status check in some tomcat init scripts
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease < 7 {
    file_line { 'fix broken tomcat init script':
      path    => "/etc/init.d/${::tomcat::service_name_real}",
      line    => "            pid=\"$(/usr/bin/pgrep -d , -u \${TOMCAT_USER} -G \${TOMCAT_USER} -f Dcatalina.base=\${CATALINA_BASE})\"",
      match   => 'pid=.*pgrep',
      require => Package['tomcat server']
    }
  }
}