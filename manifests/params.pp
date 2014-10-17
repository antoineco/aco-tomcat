# == Class: tomcat::params
#
class tomcat::params {
  case $::osfamily {
    'RedHat' : {
      case $::operatingsystem {
        'Fedora' : {
          case $::operatingsystemmajrelease {
            '20'    : {
              $version = '7.0.47'
              $service_name = 'tomcat'
            }
            '19'    : {
              $version = '7.0.47'
              $service_name = 'tomcat'
            }
            '18'    : {
              $version = '7.0.42'
              $service_name = 'tomcat'
            }
            '17'    : {
              $version = '7.0.40'
              $service_name = 'tomcat'
              # $version = '6.0.35'
              # $service_name = 'tomcat6'
            }
            '16'    : {
              $version = '7.0.33'
              $service_name = 'tomcat'
              # $version = '6.0.35'
              # $service_name = 'tomcat6'
            }
            '15'    : {
              $version = '7.0.23'
              $service_name = 'tomcat'
              # $version = '6.0.32'
              # $service_name = 'tomcat6'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
        default  : {
          case $::operatingsystemmajrelease {
            '7'     : {
              $version = '7.0.42'
              $service_name = 'tomcat'
            }
            '6'     : {
              $version = '6.0.24'
              $service_name = 'tomcat6'
              # epel
              # $version = '7.0.33'
              # $service_name = 'tomcat'
              # jpackage6
              # $version = '7.0.54'
              # $service_name = 'tomcat7'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
      }
    }
    default  : {
      fail("Unsupported OS family ${::osfamily}")
    }
  }
}