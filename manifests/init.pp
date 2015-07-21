# == Class: tomcat
#
# This module installs the Tomcat application server from available repositories or archive
#
# === Parameters:
#
# [*install_from*]
#   what type of source to install from (valid: 'package'|'archive')
# [*version*]
#   tomcat full version number (valid format: x.y.z[-package_suffix])
# [*archive_source*]
#   where to download archive from (only if installed from archive)
# [*package_name*]
#   tomcat package name
# [*service_name*]
#   tomcat service name
# [*service_ensure*]
#   whether the service should be running (valid: 'stopped'|'running')
# [*service_enable*]
#   enable service (boolean)
# [*service_start*]
#   override service startup command
# [*service_stop*]
#   override service shutdown command
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
#   install admin webapps (boolean - *only* if installed from package)
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
#    version      => '7.0.56-2ubuntu0.1',
#    service_name => 'tomcat7'
#  }
#
class tomcat (
  #
  # undef values are automatically generated within the class for convenience reasons
  #
  #..................................................................................
  # packages and service
  #..................................................................................
  $install_from               = 'package',
  $version                    = $::tomcat::params::version,
  $archive_source             = undef,
  $package_name               = $::tomcat::params::package_name,
  $service_name               = undef,
  $service_ensure             = 'running',
  $service_enable             = true,
  $service_start              = undef,
  $service_stop               = undef,
  $tomcat_user                = undef,
  $tomcat_group               = undef,
  $tomcat_native              = false,
  $tomcat_native_package_name = $::tomcat::params::tomcat_native_package_name,
  $log4j                      = false,
  $log4j_package_name         = $::tomcat::params::log4j_package_name,
  $enable_extras              = false,
  $manage_firewall            = false,
  #..................................................................................
  # security and administration
  #..................................................................................
  $admin_webapps              = true,
  $admin_webapps_package_name = undef,
  $create_default_admin       = false,
  $admin_user                 = 'tomcatadmin',
  $admin_password             = 'password',
  #..................................................................................
  # logging
  #..................................................................................
  $log_path                   = undef,
  $log4j_enable               = false,
  $log4j_conf_type            = 'ini',
  $log4j_conf_source          = "puppet:///modules/${module_name}/log4j/log4j.properties",
  #..................................................................................
  # server configuration
  #..................................................................................
  # server
  $server_control_port        = 8005,
  $server_shutdown            = 'SHUTDOWN',
  $server_address             = undef,
  $server_params              = {},
  #..................................................................................
  # listeners
  $apr_listener               = false,
  $apr_sslengine              = undef,
  # jmx
  $jmx_listener               = false,
  $jmx_registry_port          = 8050,
  $jmx_server_port            = 8051,
  $jmx_bind_address           = '',
  # custom listeners
  $listeners                  = [],
  #..................................................................................
  # service
  $svc_name                   = 'Catalina',
  $svc_params                 = {},
  #..................................................................................
  # executors
  $threadpool_executor        = false,
  $threadpool_name            = 'tomcatThreadPool',
  $threadpool_nameprefix      = 'catalina-exec-',
  $threadpool_maxthreads      = undef,
  $threadpool_minsparethreads = undef,
  $threadpool_params          = {},
  # custom executors
  $executors                  = [],
  #..................................................................................
  # connectors
  # http connector
  $http_connector             = true,
  $http_port                  = 8080,
  $http_protocol              = undef,
  $http_use_threadpool        = false,
  $http_connectiontimeout     = undef,
  $http_uriencoding           = undef,
  $http_compression           = undef,
  $http_maxthreads            = undef,
  $http_params                = {},
  # ssl connector
  $ssl_connector              = false,
  $ssl_port                   = 8443,
  $ssl_protocol               = undef,
  $ssl_use_threadpool         = false,
  $ssl_connectiontimeout      = undef,
  $ssl_uriencoding            = undef,
  $ssl_compression            = false,
  $ssl_maxthreads             = undef,
  $ssl_clientauth             = undef,
  $ssl_sslprotocol            = undef,
  $ssl_keystorefile           = undef,
  $ssl_params                 = {},
  # ajp connector
  $ajp_connector              = true,
  $ajp_port                   = 8009,
  $ajp_protocol               = 'AJP/1.3',
  $ajp_use_threadpool         = false,
  $ajp_connectiontimeout      = undef,
  $ajp_uriencoding            = undef,
  $ajp_maxthreads             = undef,
  $ajp_params                 = {},
  # custom connectors
  $connectors                 = [],
  #..................................................................................
  # engine
  $engine_name                = 'Catalina',
  $engine_defaulthost         = undef,
  $engine_jvmroute            = undef,
  $engine_params              = {},
  #..................................................................................
  # cluster (experimental)
  $use_simpletcpcluster       = false,
  $cluster_membership_port    = '45565',
  $cluster_membership_domain  = 'tccluster',
  $cluster_receiver_address   = undef,
  #..................................................................................
  # realms
  $lockout_realm              = true,
  $userdatabase_realm         = true,
  $realms                     = [],
  #..................................................................................
  # host
  $host_name                  = 'localhost',
  $host_appbase               = undef,
  $host_autodeploy            = undef,
  $host_deployOnStartup       = undef,
  $host_undeployoldversions   = undef,
  $host_unpackwars            = undef,
  $host_params                = {},
  #..................................................................................
  # valves
  $singlesignon_valve         = false,
  $accesslog_valve            = true,
  $valves                     = [],
  #..................................................................................
  # misc
  $globalnaming_resources     = [],
  #..................................................................................
  # context configuration
  #..................................................................................
  $context_params             = {},
  $context_loader             = {},
  $context_manager            = {},
  $context_realm              = {},
  $context_resources          = {},
  $context_watchedresources   = ['WEB-INF/web.xml','${catalina.base}/conf/web.xml'],
  $context_parameters         = [],
  $context_environments       = [],
  $context_listeners          = [],
  $context_valves             = [],
  $context_resourcedefs       = [],
  $context_resourcelinks      = [],
  #..................................................................................
  # environment variables
  #..................................................................................
  $config_path                = undef,
  # catalina
  $catalina_home              = undef,
  $catalina_base              = undef,
  $jasper_home                = undef,
  $catalina_tmpdir            = undef,
  $catalina_pid               = undef,
  $catalina_opts              = [],
  # java
  $java_home                  = undef,
  $java_opts                  = ['-server'],
  # debug
  $jpda_enable                = false,
  $jpda_transport             = undef,
  $jpda_address               = undef,
  $jpda_suspend               = undef,
  $jpda_opts                  = [],
  # other
  $security_manager           = false,
  $lang                       = undef,
  $shutdown_wait              = 30,
  $shutdown_verbose           = false,
  $custom_variables           = {}) inherits tomcat::params {
  # parameters validation
  validate_re($install_from, '^(package|archive)$', '$install_from must be either \'package\' or \'archive\'')
  validate_re($version, '^[0-9]\.[0-9]\.[0-9]{1,2}(?:-.*)?$', 'incorrect tomcat version number')
  validate_re($service_ensure, '^(stopped|running)$', '$service_ensure must be either \'stopped\', or \'running\'')
  validate_array($listeners, $executors, $connectors, $realms, $valves, $globalnaming_resources, $context_watchedresources, $context_parameters, $context_environments, $context_listeners, $context_valves, $context_resourcedefs, $context_resourcelinks, $catalina_opts, $java_opts, $jpda_opts)
  validate_hash($server_params, $svc_params, $threadpool_params, $http_params, $ssl_params, $ajp_params, $engine_params, $host_params, $context_params, $context_loader, $context_manager, $context_realm, $context_resources, $custom_variables)

  # split version string
  $array_version_full = split($version, '[-]')
  $version_real = $array_version_full[0]
  $array_version_real = split($version_real, '[.]')
  $maj_version = $array_version_real[0]

  # autogenerated defaults
  if $service_name == undef {
    $service_name_real = $install_from ? {
      'package' => $package_name,
      default   => "tomcat${maj_version}"
    } } else {
    $service_name_real = $service_name
  }

  if $archive_source == undef {
    $archive_source_real = "http://archive.apache.org/dist/tomcat/tomcat-${maj_version}/v${version_real}/bin/apache-tomcat-${version_real}.tar.gz"
  } else {
    $archive_source_real = $archive_source
  }

  if $admin_webapps_package_name == undef {
    $admin_webapps_package_name_real = $::osfamily ? {
      'Debian' => "${package_name}-admin",
      default  => "${package_name}-admin-webapps"
    } } else {
    $admin_webapps_package_name_real = $admin_webapps_package_name
  }

  if $catalina_home == undef {
    $catalina_home_real = "/usr/share/${service_name_real}"
  } else {
    $catalina_home_real = $catalina_home
  }

  if $catalina_base == undef {
    case $install_from {
      'package' : {
        $catalina_base_real = $::osfamily ? {
          'Debian' => "/var/lib/${service_name_real}",
          default  => $catalina_home_real
        } }
      default   : {
        $catalina_base_real = $catalina_home_real
      }
    }
  } else {
    $catalina_base_real = $catalina_base
  }

  if $jasper_home == undef {
    $jasper_home_real = $catalina_home_real
  } else {
    $jasper_home_real = $jasper_home
  }

  if $catalina_tmpdir == undef {
    case $install_from {
      'package' : {
        $catalina_tmpdir_real = $::osfamily ? {
          'Debian' => '$JVM_TMP',
          default  => "${catalina_base_real}/temp"
        } }
      default   : {
        $catalina_tmpdir_real = "${catalina_base_real}/temp"
      }
    }
  } else {
    $catalina_tmpdir_real = $catalina_tmpdir
  }

  if $catalina_pid == undef {
    case $install_from {
      'package' : {
        $catalina_pid_real = "/var/run/${service_name_real}.pid"
      }
      default   : {
        $catalina_pid_real = "/var/run/${service_name_real}/${service_name_real}.pid"
      }
    }
  } else {
    $catalina_pid_real = $catalina_pid
  }

  if $log_path == undef {
    $log_path_real = "/var/log/${service_name_real}"
  } else {
    $log_path_real = $log_path
  }

  if $config_path == undef {
    case $install_from {
      'package' : {
        $config_path_real = $::osfamily ? {
          'Debian' => "/etc/default/${service_name_real}",
          'Suse'   => "/etc/${service_name_real}/${service_name_real}.conf",
          default  => "/etc/sysconfig/${service_name_real}"
        } }
      default   : {
        $config_path_real = "${catalina_base_real}/bin/setenv.sh"
      }
    }
  } else {
    $config_path_real = $config_path
  }

  if $service_start == undef {
    case $install_from {
      'package' : { $service_start_real = '/usr/sbin/tomcat-sysd start' }
      default   : {
        $start_cmd = $jpda_enable ? {
          true    => 'jpda start',
          default => 'start'
        }
        $service_start_real = "${catalina_home_real}/bin/catalina.sh ${start_cmd}"
      }
    }
  } else {
    $service_start_real = $service_start
  }

  if $service_stop == undef {
    case $install_from {
      'package' : { $service_stop_real = '/usr/sbin/tomcat-sysd stop' }
      default   : { $service_stop_real = "${catalina_home_real}/bin/catalina.sh stop" }
    }
  } else {
    $service_stop_real = $service_stop
  }

  if $tomcat_user == undef {
    case $install_from {
      'package' : {
        $tomcat_user_real = $::osfamily ? {
          'Debian' => $service_name_real,
          default  => 'tomcat'
        } }
      default   : {
        $tomcat_user_real = 'tomcat'
      }
    }
  } else {
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
  
  $engine_defaulthost_real = $engine_defaulthost ? {
    undef   => $host_name,
    default => $engine_defaulthost
  }

  $java_opts_real = join($java_opts, ' ')
  $catalina_opts_real = join($catalina_opts, ' ')
  $jpda_opts_real = join($jpda_opts, ' ')
  
  # generate params hash
  $server_params_real = merge(delete_undef_values({
    'port'     => $server_control_port,
    'shutdown' => $server_shutdown,
    'address'  => $server_address
  }
  ), $server_params)

  $svc_params_real = merge(delete_undef_values({
    'name' => $svc_name
  }
  ), $svc_params)

  $threadpool_params_real = merge(delete_undef_values({
    'namePrefix'      => $threadpool_nameprefix,
    'maxThreads'      => $threadpool_maxthreads,
    'minSpareThreads' => $threadpool_minsparethreads
  }
  ), $threadpool_params)

  $http_params_real = merge(delete_undef_values({
    'protocol'          => $http_protocol,
    'executor'          => $http_use_threadpool ? {
      true    => $threadpool_name,
      default => undef
    },
    'connectionTimeout' => $http_connectiontimeout,
    'URIEncoding'       => $http_uriencoding,
    'compression'       => $http_compression ? {
      true    => 'on',
      default => undef
    },
    'maxThreads'        => $http_maxthreads
  }
  ), $http_params)

  $ssl_params_real = merge(delete_undef_values({
    'protocol'          => $ssl_protocol,
    'executor'          => $ssl_use_threadpool ? {
      true    => $threadpool_name,
      default => undef
    },
    'connectionTimeout' => $ssl_connectiontimeout,
    'URIEncoding'       => $ssl_uriencoding,
    'compression'       => $ssl_compression ? {
      true    => 'on',
      default => undef
    },
    'maxThreads'        => $ssl_maxthreads,
    'clientAuth'        => $ssl_clientauth,
    'sslProtocol'       => $ssl_sslprotocol,
    'keystoreFile'      => $ssl_keystorefile
  }
  ), $ssl_params)

  $ajp_params_real = merge(delete_undef_values({
    'executor'          => $ajp_use_threadpool ? {
      true    => $threadpool_name,
      default => undef
    },
    'connectionTimeout' => $ajp_connectiontimeout,
    'URIEncoding'       => $ajp_uriencoding,
    'maxThreads'        => $ajp_maxthreads
  }
  ), $ajp_params)

  $engine_params_real = merge(delete_undef_values({
    'name'        => $engine_name,
    'defaultHost' => $engine_defaulthost_real,
    'jvmRoute'    => $engine_jvmroute
  }
  ), $engine_params)

  $host_params_real = merge(delete_undef_values({
    'appBase'             => $host_appbase,
    'autoDeploy'          => $host_autodeploy,
    'deployOnStartup'     => $host_deployOnStartup,
    'undeployOldVersions' => $host_undeployoldversions,
    'unpackWARs'          => $host_unpackwars
  }
  ), $host_params)

  # should we force download extras libs?
  if $log4j_enable or $jmx_listener {
    $enable_extras_real = true
  } else {
    $enable_extras_real = $enable_extras
  }

  # start the real action
  class { 'tomcat::install': } ->
  class { 'tomcat::service': }

  class { 'tomcat::config':
    require => Class['::tomcat::install']
  }

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
