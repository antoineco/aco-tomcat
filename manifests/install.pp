# == Class: tomcat::install
#
# This class is a wrapper to install tomcat either from packages or archive
#
class tomcat::install {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  case $::tomcat::install_from {
    'package' : { contain tomcat::install::package }
    default   : { contain tomcat::install::archive }
  }

  # tomcat native library
  if $::tomcat::tomcat_native {
    package { 'tomcat native library':
      ensure => present,
      name   => $::tomcat::tomcat_native_package_name
    }
  }
}
