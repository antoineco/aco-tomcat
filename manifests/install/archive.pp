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
  if !defined(Group[$::tomcat::tomcat_group_real]) {
    group { $::tomcat::tomcat_group_real:
      ensure => present,
      system => true
    }
  }

  if !defined(User[$::tomcat::tomcat_user_real]) {
    user { $::tomcat::tomcat_user_real:
      ensure => present,
      gid    => $::tomcat::tomcat_group_real,
      home   => $::tomcat::catalina_home_real,
      system => true
    }
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
  }

  # ordering
  Staging::Extract <| title == "apache-tomcat-${::tomcat::version}.tar.gz" |> -> File <| tag == 'tomcat_tree' |>

  if $::tomcat::log_path_real != "${::tomcat::catalina_base_real}/logs" {
    file {
      'tomcat logs symlink':
        ensure => link,
        path   => "${::tomcat::catalina_base_real}/logs",
        target => $::tomcat::log_path_real,
        mode   => '0777',
        force  => true,
        tag    => 'tomcat_tree'
    }
  }

  file { $::tomcat::log_path_real:
    ensure => directory,
    path   => $::tomcat::log_path_real,
    mode   => '0660',
    alias  => 'tomcat logs directory',
    tag    => 'tomcat_tree'
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
