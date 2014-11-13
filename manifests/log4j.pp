# == Class: tomcat::log4j
#
class tomcat::log4j {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  package { 'log4j': ensure => present } ->
  file { 'log4j library':
    ensure  => link,
    owner   => 'root',
    group   => 'root',
    path    => "${::tomcat::catalina_base_real}/lib/log4j.jar",
    target  => '/usr/share/java/log4j.jar',
    seltype => 'usr_t'
  } ->
  file { 'log4j dtd file':
    ensure  => link,
    owner   => 'root',
    group   => 'root',
    path    => "${::tomcat::catalina_base_real}/lib/log4j.dtd",
    target  => '/usr/share/sgml/log4j/log4j.dtd',
    seltype => 'usr_t'
  }

  if $::tomcat::log4j_conf_type == 'xml' {
    file {
      'log4j xml configuration':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        path    => "${::tomcat::catalina_base_real}/lib/log4j.xml",
        source  => $::tomcat::log4j_conf_source,
        seltype => 'lib_t';

      'log4j ini configuration':
        ensure => absent,
        path   => "${::tomcat::catalina_base_real}/lib/log4j.properties"
    }
  } else {
    file {
      'log4j ini configuration':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        path    => "${::tomcat::catalina_base_real}/lib/log4j.properties",
        source  => $::tomcat::log4j_conf_source,
        seltype => 'lib_t';

      'log4j xml configuration':
        ensure => absent,
        path   => "${::tomcat::catalina_base_real}/lib/log4j.xml"
    }
  }

  file { 'logging configuration':
    ensure => absent,
    path   => "${::tomcat::catalina_base_real}/conf/logging.properties",
    backup => true
  }
}