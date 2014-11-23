# == Class: tomcat::params
#
class tomcat::params {
  case $::osfamily {
    'RedHat' : {
      case $::operatingsystem {
        'Fedora' : {
          case $::operatingsystemmajrelease {
            '21'    : {
              $version = '7.0.54'
              $package_name = 'tomcat'
            }
            '20'    : {
              $version = '7.0.47'
              $package_name = 'tomcat'
            }
            '19'    : {
              $version = '7.0.47'
              $package_name = 'tomcat'
            }
            '18'    : {
              $version = '7.0.42'
              $package_name = 'tomcat'
            }
            '17'    : {
              $version = '7.0.40'
              $package_name = 'tomcat'
              # $version = '6.0.35'
              # $package_name = 'tomcat6'
            }
            '16'    : {
              $version = '7.0.33'
              $package_name = 'tomcat'
              # $version = '6.0.35'
              # $package_name = 'tomcat6'
            }
            '15'    : {
              $version = '7.0.23'
              $package_name = 'tomcat'
              # $version = '6.0.32'
              # $package_name = 'tomcat6'
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
              $package_name = 'tomcat'
            }
            '6'     : {
              $version = '6.0.24'
              $package_name = 'tomcat6'
              # epel
              # $version = '7.0.33'
              # $package_name = 'tomcat'
              # jpackage6
              # $version = '7.0.54'
              # $package_name = 'tomcat7'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
      }
      $admin_webapps_package_name = "${package_name}-admin-webapps"
    }
    'Debian' : {
      case $::operatingsystem {
        'Debian' : {
          case $::operatingsystemmajrelease {
            '7'     : {
              $version = '7.0.28'
              $package_name = 'tomcat7'
              # $version = '6.0.35'
              # $package_name = 'tomcat6'
            }
            '6'     : {
              $version = '6.0.35'
              $package_name = 'tomcat6'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
        'Ubuntu' : {
          case $::operatingsystemmajrelease {
            '12.04' : {
              $version = '6.0.24'
              $package_name = 'tomcat6'
            }
            '12.10' : {
              $version = '7.0.26'
              $package_name = 'tomcat7'
              # $version = '6.0.35'
              # $package_name = 'tomcat6'
            }
            '14.04' : {
              $version = '7.0.52'
              $package_name = 'tomcat7'
              # $version = '6.0.39'
              # $package_name = 'tomcat6'
            }
            '14.10' : {
              $version = '8.0.9 '
              $package_name = 'tomcat8'
              # $version = '7.0.55'
              # $package_name = 'tomcat7'
              # $version = '6.0.41'
              # $package_name = 'tomcat6'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
        default  : {
          fail("Unsupported OS ${::operatingsystem}")
        }
      }
      $admin_webapps_package_name = "${package_name}-admin"
    }
    default  : {
      fail("Unsupported OS family ${::osfamily}")
    }
  }
}