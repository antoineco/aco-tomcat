# == Class: tomcat::service
#
# This class is a wrapper to configure the appropriate tomcat service
#
class tomcat::service {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  if $::operatingsystem == 'OpenSuSE' {
    Service { # not explicit on OpenSuSE
      provider => systemd }
  }

  case $::tomcat::install_from {
    'package' : { contain tomcat::service::package }
    default   : { contain tomcat::service::archive }
  }
}