# == Class: tomcat::log4j
#
class tomcat::log4j {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # generate OS-specific variables
  $log4j_path = $::osfamily ? {
    'RedHat' => "${::tomcat::catalina_base}/lib/log4j.jar",
    default  => '/usr/share/java/log4j-1.2.jar'
  }
  $log4j_package_name = $::osfamily ? {
    'RedHat' => 'log4j',
    default  => 'liblog4j1.2-java'
  }

  package { $log4j_package_name: ensure => present } ->
  file { 'log4j library':
    ensure  => link,
    owner   => 'root',
    group   => 'root',
    path    => $log4j_path,
    target  => '/usr/share/java/log4j.jar',
    seltype => 'usr_t'
  }

  if $::tomcat::log4j_conf_type == 'xml' {
    file {
      'log4j xml configuration':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        path    => "${::tomcat::catalina_base}/lib/log4j.xml",
        source  => $::tomcat::log4j_conf_source,
        seltype => 'lib_t';

      'log4j ini configuration':
        ensure => absent,
        path   => "${::tomcat::catalina_base}/lib/log4j.properties";

      'log4j dtd file':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        path    => "${::tomcat::catalina_base}/lib/log4j.dtd",
        source  => "puppet:///modules/${module_name}/log4j.dtd",
        seltype => 'usr_t'
    }
  } else {
    file {
      'log4j ini configuration':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        path    => "${::tomcat::catalina_base}/lib/log4j.properties",
        source  => $::tomcat::log4j_conf_source,
        seltype => 'lib_t';

      'log4j xml configuration':
        ensure => absent,
        path   => "${::tomcat::catalina_base}/lib/log4j.xml";

      'log4j dtd file':
        ensure => absent,
        path   => "${::tomcat::catalina_base}/lib/log4j.dtd"
    }
  }

  file { 'logging configuration':
    ensure => absent,
    path   => "${::tomcat::catalina_base}/conf/logging.properties",
    backup => true
  }
}