# == Class: tomcat::service
#
# This class is a wrapper to configure the appropriate tomcat service
#
class tomcat::service {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # scenarios
  # -----------------------------------------------------------------
  #| install. | package             | archive                        |
  #| init     |                     |                                |
  #|----------|---------------------|--------------------------------|
  #| sysVinit | use package script  | create init.d, use catalina.sh |
  #|----------|---------------------|--------------------------------|
  #| systemd  | use package unit    | create unit, use catalina.sh   |
  # -----------------------------------------------------------------

  case $::tomcat::install_from {
    'package' : { contain tomcat::service::package }
    default   : { contain tomcat::service::archive }
  }
}
