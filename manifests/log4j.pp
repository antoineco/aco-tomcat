# == Class: tomcat::log4j
#
class tomcat::log4j {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # warn user if log4j is not installed
  unless $::tomcat::log4j {
    warning('Logging with log4j will not work unless the log4j library is installed')
  }

  # generate OS-specific variables
  $log4j_path = $::osfamily ? {
    'Debian' => '/usr/share/java/log4j-1.2.jar',
    default  => '/usr/share/java/log4j.jar'
  }

  file { 'global log4j library':
    ensure => link,
    owner  => 'root',
    group  => 'root',
    path   => "${::tomcat::catalina_home_real}/lib/log4j.jar",
    target => $log4j_path,
    notify => Service[$::tomcat::service_name_real]
  }

  if $::tomcat::log4j_conf_type == 'xml' {
    file {
      'global log4j xml configuration':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        path   => "${::tomcat::catalina_home_real}/lib/log4j.xml",
        source => $::tomcat::log4j_conf_source,
        notify => Service[$::tomcat::service_name_real];

      'global log4j ini configuration':
        ensure => absent,
        path   => "${::tomcat::catalina_home_real}/lib/log4j.properties";

      'global log4j dtd file':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        path   => "${::tomcat::catalina_home_real}/lib/log4j.dtd",
        source => "puppet:///modules/${module_name}/log4j/log4j.dtd"
    }
  } else {
    file {
      'global log4j ini configuration':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        path   => "${::tomcat::catalina_home_real}/lib/log4j.properties",
        source => $::tomcat::log4j_conf_source,
        notify => Service[$::tomcat::service_name_real];

      'global log4j xml configuration':
        ensure => absent,
        path   => "${::tomcat::catalina_home_real}/lib/log4j.xml";

      'global log4j dtd file':
        ensure => absent,
        path   => "${::tomcat::catalina_home_real}/lib/log4j.dtd"
    }
  }

  file { 'global logging configuration':
    ensure => absent,
    path   => "${::tomcat::catalina_base_real}/conf/logging.properties",
    backup => true
  }
}
