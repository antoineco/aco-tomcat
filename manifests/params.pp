# == Class: tomcat::params
#
class tomcat::params {
  case $::osfamily {
    'RedHat' : {
      case $::operatingsystem {
        'Fedora' : {
          case $::operatingsystemmajrelease {
            '22'    : {
              $version = '7.0.59-4.fc22'
              $package_name = 'tomcat'
            }
            '21'    : {
              $version = '7.0.59-1.fc21'
              $package_name = 'tomcat'
            }
            '20'    : {
              $version = '7.0.52-2.fc20'
              $package_name = 'tomcat'
            }
            '19'    : {
              $version = '7.0.47-1.fc19'
              $package_name = 'tomcat'
            }
            '18'    : {
              $version = '7.0.42-1.fc18'
              $package_name = 'tomcat'
            }
            '17'    : {
              $version = '7.0.40-1.fc17'
              $package_name = 'tomcat'
              # $version = '6.0.35-1.fc17'
              # $package_name = 'tomcat6'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
          $systemd = true
        }
        default  : {
          case $::operatingsystemmajrelease {
            '7'     : {
              $version = '7.0.54-2.el7_1'
              $package_name = 'tomcat'
              $systemd = true
            }
            '6'     : {
              $version = '6.0.24-83.el6_6'
              $package_name = 'tomcat6'
              # = epel repo =
              # $version = '7.0.33-4.el6'
              # $package_name = 'tomcat'
              # = jpackage6 repo =
              # $version = '5.5.35-1.jpp6'
              # $package_name = 'tomcat5'
              # $version = '6.0.33-2.jpp6'
              # $package_name = 'tomcat6'
              # $version = '7.0.54-2.jpp6'
              # $package_name = 'tomcat7'
              $systemd = false
            }
            '5'     : {
              $version = '5.5.23-0jpp.40.el5_9'
              $package_name = 'tomcat5'
              # = jpackage5 repo =
              # $version = '5.5.27-7.jpp5'
              # $package_name = 'tomcat5'
              # $version = '6.0.36-1.jpp5'
              # $package_name = 'tomcat6'
              $systemd = false
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
      }
      $tomcat_native_package_name = 'tomcat-native'
      $log4j_package_name = 'log4j'
    }
    'Suse'   : {
      case $::operatingsystem {
        'OpenSuSE'           : {
          case $::operatingsystemrelease {
            '13.2'  : {
              $version = '7.0.55-2.5'
              $package_name = 'tomcat'
              # = JAVA repo =
              # $version = '8.0.23-86.16'
              # $package_name = 'tomcat'
            }
            '13.1'  : {
              $version = '7.0.42-4.4.6'
              $package_name = 'tomcat'
            }
            '12.3'  : {
              $version = '7.0.42-2.43.1'
              $package_name = 'tomcat'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemrelease}")
            }
          }
          $systemd = true
        }
        /^(SLES|SLED|SuSE)$/ : {
          case $::operatingsystemrelease {
            '12.0'  : {
              $version = '7.0.55-2.77'
              $package_name = 'tomcat'
              # = JAVA repo =
              # $version = '8.0.23-86.5'
              # $package_name = 'tomcat'
              $systemd = true
            }
            '11.3'  : {
              $version = '6.0.18-20.35.40.1'
              $package_name = 'tomcat6'
              # = JAVA repo =
              # $version = '7.0.54-60.1'
              # $package_name = 'tomcat'
              $systemd = false
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemrelease}")
            }
          }
        }
        default              : {
          fail("Unsupported OS ${::operatingsystem}")
        }
      }
      $tomcat_native_package_name = 'libtcnative-1-0'
      $log4j_package_name = 'log4j'
    }
    'Debian' : {
      case $::operatingsystem {
        'Debian' : {
          case $::operatingsystemmajrelease {
            '8'     : {
              $version = '8.0.14-1'
              $package_name = 'tomcat8'
              # $version = '7.0.56-3'
              # $package_name = 'tomcat7'
            }
            '7'     : {
              $version = '7.0.28-4+deb7u1'
              $package_name = 'tomcat7'
              # $version = '6.0.35-6+deb7u1'
              # $package_name = 'tomcat6'
            }
            '6'     : {
              $version = '6.0.35-1+squeeze4'
              $package_name = 'tomcat6'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
        'Ubuntu' : {
          case $::operatingsystemrelease {
            '15.04' : {
              $version = '8.0.14-1'
              $package_name = 'tomcat8'
              # $version = '7.0.56-2ubuntu0.1'
              # $package_name = 'tomcat7'
              # $version = '6.0.41-1'
              # $package_name = 'tomcat6'
            }
            '14.10' : {
              $version = '8.0.9-1'
              $package_name = 'tomcat8'
              # $version = '7.0.55-1ubuntu0.2'
              # $package_name = 'tomcat7'
              # $version = '6.0.41-1'
              # $package_name = 'tomcat6'
            }
            '14.04' : {
              $version = '7.0.52-1ubuntu0.3'
              $package_name = 'tomcat7'
              # $version = '6.0.39-1'
              # $package_name = 'tomcat6'
            }
            '13.10' : {
              $version = '7.0.42-1ubuntu0.1'
              $package_name = 'tomcat7'
              # $version = '6.0.37-1'
              # $package_name = 'tomcat6'
            }
            '13.04' : {
              $version = '7.0.35-1~exp2ubuntu1.1'
              $package_name = 'tomcat7'
              # $version = '6.0.35-6'
              # $package_name = 'tomcat6'
            }
            '12.10' : {
              $version = '7.0.30-0ubuntu1.3'
              $package_name = 'tomcat7'
              # $version = '6.0.35-5ubuntu0.1'
              # $package_name = 'tomcat6'
            }
            '12.04' : {
              $version = '7.0.26-1ubuntu1.2'
              $package_name = 'tomcat7'
              # $version = '6.0.35-1ubuntu3.6'
              # $package_name = 'tomcat6'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemrelease}")
            }
          }
        }
        default  : {
          fail("Unsupported OS ${::operatingsystem}")
        }
      }
      $tomcat_native_package_name = 'libtcnative-1'
      $log4j_package_name = 'liblog4j1.2-java'
      $systemd = false
    }
    default  : {
      fail("Unsupported OS family ${::osfamily}")
    }
  }
}
