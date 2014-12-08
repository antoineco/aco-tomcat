# == Class: tomcat::service
#
class tomcat::service {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  service { $::tomcat::service_name:
    ensure  => $::tomcat::service_ensure,
    enable  => $::tomcat::service_enable
  }
}