# == Class: tomcat::install
#
class tomcat::install {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # main packages
  package { 'tomcat server':
    name   => "$::tomcat::package_name",
    ensure => present
  }
  if $::tomcat::tomcat_native {
    package { 'tomcat-native': ensure => present }
  }

  # install admin webapps
  $ensure_manager_package = $::tomcat::enable_manager ? {
    true    => 'present',
    default => 'absent'
  }
  package { 'tomcat admin webapps':
    name   => "${::tomcat::package_name}-admin-webapps",
    ensure => $ensure_manager_package
  }
}
