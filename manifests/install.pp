# == Class: tomcat::install
#
# This class is a wrapper to install tomcat either from packages or archive
#
class tomcat::install {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  case $::tomcat::installation_support {
    'package' : { contain ::tomcat::install::package }
    default   : { contain ::tomcat::install::archive }
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

  # log4j library
  $ensure_log4j_package = $::tomcat::log4j ? {
    true    => 'present',
    default => 'absent'
  }
  package { 'tomcat log4j library':
    ensure => $ensure_log4j_package,
    name   => $::tomcat::log4j_package_name
  }

  # install admin webapps
  if $tomcat::installation_support == 'package' {
    $ensure_manager_package = $::tomcat::admin_webapps ? {
      true    => 'present',
      default => 'absent'
    }
    package { 'tomcat admin webapps':
      ensure => $ensure_manager_package,
      name   => $::tomcat::admin_webapps_package_name_real
    }
  }
}