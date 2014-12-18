# == Class: tomcat::service
#
# This class is a wrapper to configure the appropriate tomcat service
#
class tomcat::service {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  case $::tomcat::installation_support {
    'package' : { contain ::tomcat::service::package }
    default   : { contain ::tomcat::service::archive }
  }
}