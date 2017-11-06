# == Class: tomcat::params
#
class tomcat::params {
  case $::osfamily {
    'RedHat' : {
      case $::operatingsystem {
        'Fedora' : {
          case $::operatingsystemmajrelease {
            # https://dl.fedoraproject.org/pub/fedora/linux/updates/26/x86_64/t/
            '26'    : {
              $version = '1:8.0.46'
              $package_name = 'tomcat'
            }
            # https://dl.fedoraproject.org/pub/fedora/linux/updates/25/x86_64/t/
            '25'    : {
              $version = '1:8.0.46'
              $package_name = 'tomcat'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
          $systemd = true
        }
        'Amazon' : {
          # https://alas.aws.amazon.com
          $version = '8.5.23'           # ALAS-2017-913
          $package_name = 'tomcat8'
          # $version = '7.0.82'         # ALAS-2017-913
          # $package_name = 'tomcat7'
          # $version = '6.0.53'         # ALAS-2017-821
          # $package_name = 'tomcat6'
          $systemd = false
        }
        default  : {
          case $::operatingsystemmajrelease {
            # http://mirror.centos.org/centos-7/7/updates/x86_64/Packages/
            '7'     : {
              $version = '7.0.76'
              $package_name = 'tomcat'
              $systemd = true
            }
            # http://mirror.centos.org/centos-6/6/updates/x86_64/Packages/
            '6'     : {
              $version = '6.0.24'
              $package_name = 'tomcat6'
              # = epel repo =
              # https://dl.fedoraproject.org/pub/epel/6/x86_64/
              # $version = '7.0.72-1.el6'
              # $package_name = 'tomcat'
              # = jpackage6 repo =
              # http://mirrors.dotsrc.org/jpackage/6.0/generic/free/repoview/letter_t.group.html
              # $version = '5.5.35-1.jpp6'
              # $package_name = 'tomcat5'
              # $version = '6.0.33-2.jpp6'
              # $package_name = 'tomcat6'
              # $version = '7.0.54-2.jpp6'
              # $package_name = 'tomcat7'
              $systemd = false
            }
            # http://vault.centos.org/5.11/os/x86_64/CentOS/
            '5'     : {
              $version = '5.5.23'
              $package_name = 'tomcat5'
              # = jpackage5 repo =
              # http://mirrors.dotsrc.org/jpackage/5.0-updates/generic/free/repoview/letter_t.group.html
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
    }
    'Suse'   : {
      case $::operatingsystem {
        'OpenSuSE'           : {
          case $::operatingsystemrelease {
            '42.3'  : {
              # http://download.opensuse.org/distribution/leap/42.3/repo/oss/suse/noarch/
              # http://download.opensuse.org/update/leap/42.3/oss/noarch/
              $version = '8.0.43'
              $package_name = 'tomcat'
            }
            '42.2'  : {
              # http://download.opensuse.org/distribution/leap/42.2/repo/oss/suse/noarch/
              # http://download.opensuse.org/update/leap/42.2/oss/noarch/
              $version = '8.0.43'
              $package_name = 'tomcat'
              # = JAVA repo =
              # http://download.opensuse.org/repositories/Java:/packages/openSUSE_Leap_42.2/noarch/
              # $version = '8.0.39-118.8'
              # $package_name = 'tomcat'
            }
            '42.1'  : {
              # http://download.opensuse.org/distribution/leap/42.1/repo/oss/suse/noarch/
              # http://download.opensuse.org/update/leap/42.1/oss/noarch/
              $version = '8.0.43'
              $package_name = 'tomcat'
              # = JAVA repo =
              # http://download.opensuse.org/repositories/Java:/packages/openSUSE_Leap_42.1/noarch/
              # $version = '8.0.39-118.6'
              # $package_name = 'tomcat'
            }
            '13.2'  : {
              # http://download.opensuse.org/distribution/13.2/repo/oss/suse/noarch/
              $version = '7.0.55'
              $package_name = 'tomcat'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemrelease}")
            }
          }
          $systemd = true
        }
        /^(SLES|SLED|SuSE)$/ : {
          # https://download.suse.com/patch/finder
          case $::operatingsystemrelease {
            '12.3'  : {
              $version = '8.0.43'
              $package_name = 'tomcat'
              $systemd = true
            }
            '12.2'  : {
              $version = '8.0.43'
              $package_name = 'tomcat'
              $systemd = true
            }
            '12.1'  : {
              $version = '8.0.43'
              $package_name = 'tomcat'
              # = JAVA repo =
              # http://download.opensuse.org/repositories/Java:/packages/SLE_12_SP1/noarch/
              # $version = ''
              $systemd = true
            }
            '12.0'  : {
              $version = '7.0.68'
              $package_name = 'tomcat'
              $systemd = true
            }
            '11.4'  : {
              $version = '6.0.45'
              $package_name = 'tomcat6'
              $systemd = false
            }
            '11.3'  : {
              $version = '6.0.41'
              $package_name = 'tomcat6'
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
    }
    'Debian' : {
      case $::operatingsystem {
        'Debian' : {
          case $::operatingsystemmajrelease {
            # stretch
            # https://packages.debian.org/stretch/tomcat8
            '9'     : {
              $version = '8.5.14-1+deb9u2'
              $package_name = 'tomcat8'
            }
            # jessie
            # https://packages.debian.org/jessie/tomcat8
            '8'     : {
              $version = '8.0.14-1+deb8u11'
              $package_name = 'tomcat8'
              # $version = '7.0.56-3+deb8u10'
              # $package_name = 'tomcat7'
            }
            # wheezy
            # https://packages.debian.org/wheezy/tomcat7
            '7'     : {
              $version = '7.0.28-4+deb7u15'
              $package_name = 'tomcat7'
              # $version = '6.0.45+dfsg-1~deb7u5'
              # $package_name = 'tomcat6'
            }
            default : {
              fail("Unsupported OS version ${::operatingsystemmajrelease}")
            }
          }
        }
        'Ubuntu' : {
          case $::operatingsystemrelease {
            # artful
            # https://packages.ubuntu.com/artful/tomcat8
            '17.10' : {
              $version = '8.5.21-1ubuntu1'
              $package_name = 'tomcat8'
            }
            # zesty
            # http://packages.ubuntu.com/zesty/tomcat8
            '17.04' : {
              $version = '8.0.38-2ubuntu2'
              $package_name = 'tomcat8'
            }
            # yakkety
            '16.10' : {
              $version = '8.0.37-1ubuntu0.1'
              $package_name = 'tomcat8'
              # $version = '7.0.72-1'
              # $package_name = 'tomcat7'
            }
            # xenial
            # https://packages.ubuntu.com/xenial-updates/tomcat8
            '16.04' : {
              $version = '8.0.32-1ubuntu1.4'
              $package_name = 'tomcat8'
              # $version = '7.0.68-1ubuntu0.1'
              # $package_name = 'tomcat7'
            }
            # wily
            '15.10' : {
              $version = '8.0.26-1'
              $package_name = 'tomcat8'
              # $version = '7.0.64-1ubuntu0.3'
              # $package_name = 'tomcat7'
            }
            # vivid
            '15.04' : {
              $version = '8.0.14-1+deb8u1build0.15.04.1'
              $package_name = 'tomcat8'
              # $version = '7.0.56-2ubuntu0.1'
              # $package_name = 'tomcat7'
            }
            # utopic
            '14.10' : {
              $version = '8.0.9-1'
              $package_name = 'tomcat8'
              # $version = '7.0.55-1ubuntu0.2'
              # $package_name = 'tomcat7'
              # $version = '6.0.41-1'
              # $package_name = 'tomcat6'
            }
            # trusty
            # https://packages.ubuntu.com/trusty-updates/tomcat7
            '14.04' : {
              $version = '7.0.52-1ubuntu0.11'
              $package_name = 'tomcat7'
              # $version = '6.0.39-1'
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
      $systemd = false
    }
    default  : {
      fail("Unsupported OS family ${::osfamily}")
    }
  }
}
