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
    ensure => directory
  }

  archive { "apache-tomcat-${::tomcat::version_real}.tar.gz":
    path            => "${::tomcat::catalina_home_real}/apache-tomcat-${::tomcat::version_real}.tar.gz",
    source          => "${::tomcat::archive_source_real}/${::tomcat::archive_filename_real}",
    proxy_server    => $::tomcat::proxy_server,
    proxy_type      => $::tomcat::proxy_type,
    cleanup         => true,
    extract         => true,
    user            => $::tomcat::tomcat_user_real,
    group           => $::tomcat::tomcat_group_real,
    checksum_verify => $::tomcat::checksum_verify,
    checksum_type   => $::tomcat::checksum_type,
    checksum        => $::tomcat::checksum,
    extract_path    => $::tomcat::catalina_home_real,
    extract_command => 'tar xf %s --strip-components=1',
    creates         => "${::tomcat::catalina_home_real}/LICENSE",
    require         => File[$::tomcat::catalina_home_real]
  }


  # ordering
  Archive["apache-tomcat-${::tomcat::version_real}.tar.gz"] -> File <| tag == 'tomcat_tree' |>

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
      mode   => $::tomcat::log_folder_mode,
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
