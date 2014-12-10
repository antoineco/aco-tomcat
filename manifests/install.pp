# == Class: tomcat::install
#
class tomcat::install {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # main packages
  package { 'tomcat server':
    ensure => $::tomcat::version,
    name   => $::tomcat::package_name
  }

  # tomcat native library
  $ensure_native_package = $::tomcat::tomcat_native ? {
    true    => 'present',
    default => 'absent'
  }
  package { 'tomcat native library':
    ensure => $ensure_native_package,
    name   => $::tomcat::tomcat_native_package_name
  }

  # install admin webapps
  $ensure_manager_package = $::tomcat::admin_webapps ? {
    true    => 'present',
    default => 'absent'
  }
  package { 'tomcat admin webapps':
    ensure => $ensure_manager_package,
    name   => $::tomcat::admin_webapps_package_name_real
  }
}