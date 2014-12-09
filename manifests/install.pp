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

  # tomcat native library
  $ensure_native_package = $::tomcat::tomcat_native ? {
    true    => 'present',
    default => 'absent'
  }
  package { 'tomcat native library':
    name   => $::tomcat::tomcat_native_package_name,
    ensure => $ensure_native_package
  }

  # install admin webapps
  $ensure_manager_package = $::tomcat::admin_webapps ? {
    true    => 'present',
    default => 'absent'
  }
  package { 'tomcat admin webapps':
    name   => $::tomcat::admin_webapps_package_name_real,
    ensure => $ensure_manager_package
  }
}