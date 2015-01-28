# == Class: tomcat::install::archive
#
# This class installs tomcat from an archive
#
class tomcat::install::archive {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # create user if not present
  group { $::tomcat::tomcat_group_real:
    ensure => present,
    system => true
  } ->
  user { $::tomcat::tomcat_user_real:
    ensure => present,
    gid    => $::tomcat::tomcat_group_real,
    home   => $::tomcat::catalina_home_real,
    system => true
  }

  File {
    owner => $::tomcat::tomcat_user_real,
    group => $::tomcat::tomcat_group_real,
    mode  => '0644'
  }

  # install from archive
  file { $::tomcat::catalina_home_real:
    ensure => directory
  } ->
  staging::file { "apache-tomcat-${::tomcat::version}.tar.gz": source => $::tomcat::archive_source_real } ->
  staging::extract { "apache-tomcat-${::tomcat::version}.tar.gz":
    target  => $::tomcat::catalina_home_real,
    creates => "${::tomcat::catalina_home_real}/bin",
    user    => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
    strip   => 1
  } ->
  file { 'tomcat logs symlink':
    ensure => link,
    path   => "${::tomcat::catalina_base_real}/logs",
    target => "/var/log/${::tomcat::service_name_real}",
    mode   => '0777',
    force  => true
  }

  file { 'tomcat logs directory':
    ensure => directory,
    path   => "/var/log/${::tomcat::service_name_real}",
    mode   => '0660',
  }
  
  # pid file management
  file { 'tomcat pid file':
    ensure => present,
    path   => $::tomcat::catalina_pid_real
  }

  # warn if admin webapps were selected for installation
  if $::tomcat::admin_webapps {
    warning("tomcat archives always contain admin webapps, ignoring parameter 'admin_webapps'")
  }
}