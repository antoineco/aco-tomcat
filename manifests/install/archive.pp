# == Class: tomcat::install::archive
#
# This class installs tomcat from an archive
#
class tomcat::install::archive {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }


  # dependency
  if !defined(Class['archive']) {
    include archive
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

  file { $::tomcat::catalina_home_real:
    ensure => directory,
  } ->
  archive { "${::tomcat::catalina_home_real}/apache-tomcat-${::tomcat::version_real}.tar.gz":
    source          => $::tomcat::archive_source_real,
    cleanup         => true,
    extract         => true,
    checksum        => $::tomcat::checksum,
    checksum_verify => $::tomcat::checksum_verify,
    checksum_type   => $::tomcat::checksum_type,
    extract_path    => dirname($::tomcat::catalina_home_real),
    creates         => "${::tomcat::catalina_home_real}/bin"
  }


  # ordering
  Archive <| title == $::tomcat::catalina_base_real |> -> File <| tag == 'tomcat_tree' |>

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

  if !defined(File[$::tomcat::log_path_real]) {
    file { $::tomcat::log_path_real:
      ensure => directory,
      path   => $::tomcat::log_path_real,
      mode   => '0660',
      alias  => 'tomcat logs directory',
      tag    => 'tomcat_tree'
    }
  }

  # default pid file directory
  file { 'tomcat pid directory':
    ensure => directory,
    path   => "/var/run/${::tomcat::service_name_real}",
    owner  => $::tomcat::tomcat_user_real,
    group  => $::tomcat::tomcat_group_real
  }

  # warn if admin webapps were selected for installation
  if $::tomcat::admin_webapps {
    warning("tomcat archives always contain admin webapps, ignoring parameter 'admin_webapps'")
  }
}
