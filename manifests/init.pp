# == Class: tomcat
#
# This module installs the Tomcat application server from available repositories
#
# === Parameters:
#
# [*version*]
#   tomcat full version number (valid format: x.y.z)
# [*package_name*]
#   tomcat package name
# [*service_name*]
#   tomcat service name
# [*service_ensure*]
#   whether the service should be running (valid: 'stopped'|'running')
# [*service_enable*]
#   enable service (boolean)
# [*tomcat_native*]
#   install tomcat native library (boolean)
# [*tomcat_native_package_name*]
#   tomcat native library package name
# [*log4j*]
#   install log4j libraries (boolean)
# [*log4j_package_name*]
#   log4j package name
# [*enable_extras*]
#   install extra libraries (boolean)
# [*manage_firewall*]
#   manage firewall rules (boolean)
# [*admin_webapps*]
#   install admin webapps (boolean)
# [*admin_webapps_package_name*]
#   admin webapps package name
# [*create_default_admin*]
#   create default admin user (boolean)
# [*admin_user*]
#   admin user name
# [*admin_password*]
#   admin user password
#
# see README file for a description of all parameters related to server configuration
#
# === Actions:
#
# * Install tomcat
# * Configure main instance
# * Download extra libraries (optional)
#
# === Requires:
#
# * puppetlabs/stdlib module
# * puppetlabs/concat module
#
# === Sample Usage:
#
#  class { '::tomcat':
#    version      => '7.0.54',
#    service_name => 'tomcat7'
#  }
#
class tomcat (
  #
  # undef values are automatically generated within the class for convenience reasons
  #
  #----------------------------------------------------------------------------------
  # packages and service
  #----------------------------------------------------------------------------------
  $version              = $::tomcat::params::version,
  $package_name         = $::tomcat::params::package_name,
  $service_name         = undef,
  $service_ensure       = 'running',
  $service_enable       = true,
  $tomcat_native        = false,
  $tomcat_native_package_name = $::tomcat::params::tomcat_native_package_name,
  $log4j                = false,
  $log4j_package_name   = $::tomcat::params::log4j_package_name,
  $enable_extras        = false,
  $manage_firewall      = false,
  #----------------------------------------------------------------------------------
  # security and administration
  #----------------------------------------------------------------------------------
  $admin_webapps        = true,
  $admin_webapps_package_name = undef,
  $create_default_admin = true,
  $admin_user           = 'tomcatadmin',
  $admin_password       = 'password',
  #----------------------------------------------------------------------------------
  # logging
  #----------------------------------------------------------------------------------
  $log4j_enable         = false,
  $log4j_conf_type      = 'ini',
  $log4j_conf_source    = "puppet:///modules/${module_name}/log4j/log4j.properties",
  #----------------------------------------------------------------------------------
  # server configuration
  #----------------------------------------------------------------------------------
  # listeners
  $apr_listener         = false,
  $apr_sslengine        = 'on',
  # jmx
  $jmx_listener         = false,
  $jmx_registry_port    = 8050,
  $jmx_server_port      = 8051,
  $jmx_bind_address     = '',
  #----------------------------------------------------------------------------------
  # server
  $control_port         = 8005,
  #----------------------------------------------------------------------------------
  # executor
  $threadpool_executor  = false,
  #----------------------------------------------------------------------------------
  # http connector
  $http_connector       = true,
  $http_port            = 8080,
  $use_threadpool       = false,
  #----------------------------------------------------------------------------------
  # ssl connector
  $ssl_connector        = false,
  $ssl_port             = 8443,
  #----------------------------------------------------------------------------------
  # ajp connector
  $ajp_connector        = true,
  $ajp_port             = 8009,
  #----------------------------------------------------------------------------------
  # engine
  $jvmroute             = undef,
  #----------------------------------------------------------------------------------
  # host
  $hostname             = 'localhost',
  $autodeploy           = true,
  $deployOnStartup      = true,
  $undeployoldversions  = false,
  $unpackwars           = true,
  #----------------------------------------------------------------------------------
  # valves
  $singlesignon_valve   = false,
  $accesslog_valve      = true,
  #----------------------------------------------------------------------------------
  # global configuration file
  #----------------------------------------------------------------------------------
  $config_path          = undef,
  $catalina_home        = undef,
  $catalina_base        = undef,
  $jasper_home          = undef,
  $catalina_tmpdir      = undef,
  $catalina_pid         = undef,
  $java_home            = undef,
  $java_opts            = ['-server'],
  $catalina_opts        = [],
  $security_manager     = false,
  $tomcat_user          = undef,
  $tomcat_group         = undef,
  $lang                 = undef,
  $shutdown_wait        = 30,
  $shutdown_verbose     = false,
  $custom_fragment      = undef) inherits tomcat::params {
  # autogenerated defaults
  if $service_name == undef {
    $service_name_real = $package_name
  } else {
    $service_name_real = $service_name
  }

  if $admin_webapps_package_name == undef {
    $admin_webapps_package_name_real = $::osfamily ? {
      'RedHat' => "${package_name}-admin-webapps",
      default  => "${package_name}-admin"
    } } else {
    $admin_webapps_package_name_real = $admin_webapps_package_name
  }
  
  if $config_path == undef {
    $config_path_real = $::osfamily ? {
      'RedHat' => "/etc/sysconfig/${service_name_real}",
      default  => "/etc/default/${service_name_real}"
    }
  } else {
    $config_path_real = $config_path
  }

  if $catalina_home == undef {
    $catalina_home_real = "/usr/share/${service_name_real}"
  } else {
    $catalina_home_real = $catalina_home
  }

  if $catalina_base == undef {
    $catalina_base_real = $::osfamily ? {
      'RedHat' => $catalina_home_real,
      default  => "/var/lib/${service_name_real}"
    } } else {
    $catalina_base_real = $catalina_base
  }

  if $jasper_home == undef {
    $jasper_home_real = $catalina_home_real
  } else {
    $jasper_home_real = $jasper_home
  }

  if $catalina_tmpdir == undef {
    $catalina_tmpdir_real = $::osfamily ? {
      'Debian' => '$JVM_TMP',
      default  => "${catalina_base_real}/temp"
    } } else {
    $catalina_tmpdir_real = $catalina_tmpdir
  }

  if $catalina_pid == undef {
    $catalina_pid_real = "/var/run/${service_name_real}.pid"
  } else {
    $catalina_pid_real = $catalina_pid
  }
  
  $java_opts_real = join($java_opts, ' ')
  $catalina_opts_real = join($catalina_opts, ' ')

  if $tomcat_user == undef {
    $tomcat_user_real = $::osfamily ? {
      'RedHat' => 'tomcat',
      default  => $package_name
    } } else {
    $tomcat_user_real = $tomcat_user
  }

  if $tomcat_group == undef {
    $tomcat_group_real = $tomcat_user_real
  } else {
    $tomcat_group_real = $tomcat_group
  }

  if $::osfamily == 'Debian' {
    $security_manager_real = $security_manager ? {
      true    => 'yes',
      default => 'no'
    } } else {
    $security_manager_real = $security_manager
  }

  # get major version
  $array_version = split($version, '[.]')
  $maj_version = $array_version[0]

  # should we force download extras libs?
  if $log4j_enable or $jmx_listener {
    $enable_extras_real = true
  } else {
    $enable_extras_real = $enable_extras
  }
  
  # module dependency
  if !defined(Class['archive']) {
    include ::archive
  }

  # start the real action
  include tomcat::install
  include tomcat::service

  class { 'tomcat::config':
    require => Class['::tomcat::install']
  }

  Class['::tomcat::install'] ->
  Class['::tomcat::service']

  if $log4j_enable {
    class { 'tomcat::log4j':
      require => Class['::tomcat::install']
    }
  }

  if $enable_extras_real {
    class { 'tomcat::extras':
      require => Class['::tomcat::install']
    }
  }

  if $manage_firewall {
    include ::tomcat::firewall
  }
}