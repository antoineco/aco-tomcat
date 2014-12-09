# == Class: tomcat
#
# This module installs the Tomcat application server from available repositories on RHEL variants
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
# [*extras*]
#   install extra libraries (boolean)
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
# see README file for a description of the other parameters
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
  #----------------------------------------------------------------------------------
  # packages and service
  #----------------------------------------------------------------------------------
  $version                    = $::tomcat::params::version,
  $package_name               = $::tomcat::params::package_name,
  $service_name               = $::tomcat::params::service_name,
  $service_ensure             = 'running',
  $service_enable             = true,
  $tomcat_native              = false,
  $tomcat_native_package_name = $::tomcat::params::tomcat_native_package_name,
  $extras                     = false,
  #----------------------------------------------------------------------------------
  # security and administration
  #----------------------------------------------------------------------------------
  $admin_webapps              = true,
  $admin_webapps_package_name = $::tomcat::params::admin_webapps_package_name,
  $create_default_admin       = true,
  $admin_user                 = 'tomcatadmin',
  $admin_password             = 'password',
  #----------------------------------------------------------------------------------
  # server configuration
  #----------------------------------------------------------------------------------
  $control_port        = 8005,
  # executors
  $threadpool_executor = false,
  # http connector
  $http_connector      = true,
  $http_port           = 8080,
  $use_threadpool      = false,
  #----------------------------------------------------------------------------------
  # ssl connector
  $ssl_connector = false,
  $ssl_port      = 8443,
  #----------------------------------------------------------------------------------
  # ajp connector
  $ajp_connector = true,
  $ajp_port      = 8009,
  #----------------------------------------------------------------------------------
  # engine
  $defaulthost = 'localhost',
  #----------------------------------------------------------------------------------
  # host
  $hostname            = 'localhost',
  $jvmroute            = '',
  $autodeploy          = true,
  $deployOnStartup     = true,
  $undeployoldversions = false,
  $unpackwars          = true,
  $singlesignon_valve  = false,
  $accesslog_valve     = true,
  #----------------------------------------------------------------------------------
  # jmx
  $jmx_listener      = false,
  $jmx_registry_port = 8050,
  $jmx_server_port   = 8051,
  #----------------------------------------------------------------------------------
  # global configuration file
  #----------------------------------------------------------------------------------
  $catalina_base    = $::tomcat::params::catalina_base,
  $catalina_home    = $::tomcat::params::catalina_home,
  $jasper_home      = $::tomcat::params::jasper_home,
  $catalina_tmpdir  = $::tomcat::params::catalina_tmpdir,
  $catalina_pid     = $::tomcat::params::catalina_pid,
  $java_home        = '/usr/lib/jvm/jre',
  $java_opts        = '-server',
  $catalina_opts    = '',
  $security_manager = false,
  $tomcat_user      = $::tomcat::params::tomcat_user,
  $tomcat_group     = $::tomcat::params::tomcat_group,
  $lang             = '',
  $shutdown_wait    = 30,
  $shutdown_verbose = false,
  $custom_fragment  = '',
  #----------------------------------------------------------------------------------
  # log4j
  $log4j              = false,
  $log4j_package_name = $::tomcat::params::log4j_package_name,
  $log4j_conf_type    = 'ini',
  $log4j_conf_source  = "puppet:///modules/${module_name}/log4j.properties") inherits tomcat::params {

  # get major version
  $array_version = split($version, '[.]')
  $maj_version = $array_version[0]

  # should we force download extras libs?
  if $log4j or $jmx_listener {
    $extras_real = true
  } else {
    $extras_real = $extras
  }

  # start the real action
  include tomcat::install
  include tomcat::service
  class { 'tomcat::config':
    require => Class['::tomcat::install'],
    notify  => Class['::tomcat::service']
  }
 
  Class['::tomcat::install'] ~>
  Class['::tomcat::service']

  if $log4j {
    class { 'tomcat::log4j':
      require => Class['::tomcat::install'],
      notify  => Class['::tomcat::service']
    }
  }

  if $extras_real {
    class { 'tomcat::extras':
      require => Class['::tomcat::install'],
      notify  => Class['::tomcat::service']
    }
  }
}