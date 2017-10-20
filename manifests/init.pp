# == Class: tomcat
#
# This module installs the Tomcat application server from available repositories or archive
#
# === Parameters:
#
# [*install_from*]
#   what type of source to install from (valid: 'package'|'archive')
# [*version*]
#   tomcat full version number (valid format: x.y.z[.M##][-package_suffix])
# [*archive_source*]
#   base path to the archive to download (only if installed from archive)
# [*archive_filename*]
#   file name of the archive to download (only if installed from archive)
# [*proxy_server*]
#   proxy server url
# [*proxy_type*]
#   proxy server type (valid: 'none'|'http'|'https'|'ftp')
# [*package_name*]
#   tomcat package name
# [*package_ensure*]
#   tomcat package 'ensure' attribute (falls back to value of '$version')
# [*service_name*]
#   tomcat service name
# [*service_ensure*]
#   whether the service should be running (valid: 'stopped'|'running')
# [*service_enable*]
#   enable service (boolean)
# [*systemd_service_type*]
#   value for systemd service type
# [*force_init*]
#   force generation of a generic init script/unit
# [*service_start*]
#   override service startup command
# [*service_stop*]
#   override service shutdown command
# [*tomcat_user*]
#   service user
# [*tomcat_group*]
#   service group
# [*file_mode*]
#   mode for configuration files
# [*tomcat_native*]
#   install tomcat native library (boolean)
# [*tomcat_native_package_name*]
#   tomcat native library package name
# [*extras_enable*]
#   install extra libraries (boolean)
# [*extras_source*]
#   base path to tomcat extra libraries
# [*extras_package_name*]
#   install extras from given package(s)
# [*manage_firewall*]
#   manage firewall rules (boolean)
# [*checksum_verify*]
#   verify the checksum if tomcat is installed from an archive (boolean)
# [*checksum_type*]
#   archive file checksum type (valid: 'none'|'md5'|'sha1'|'sha2'|'sh256'|'sha384'|'sha512')
# [*checksum*]
#   archive file checksum
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
# [*tomcat_users*]
#   hash containing user definitions
# [*tomcat_roles*]
#   hash containing role definitions
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
  $archive_filename           = undef,
  $proxy_server               = undef,
  $proxy_type                 = undef,
  $package_name               = $::tomcat::params::package_name,
  $package_ensure             = undef,
  $service_name               = undef,
  $service_ensure             = 'running',
  $service_enable             = true,
  $restart_on_change          = true,
  $systemd_service_type       = undef,
  $force_init                 = false,
  $service_start              = undef,
  $service_stop               = undef,
  $tomcat_user                = undef,
  $tomcat_group               = undef,
  $file_mode                  = '0600',
  $tomcat_native              = false,
  $tomcat_native_package_name = $::tomcat::params::tomcat_native_package_name,
  $extras_enable              = false,
  $extras_source              = undef,
  $extras_package_name        = undef,
  $manage_firewall            = false,
  #..................................................................................
  # checksum for archive file
  #..................................................................................
  $checksum_verify            = false,
  $checksum_type              = 'none',
  $checksum                   = undef,
  #..................................................................................
  # security and administration
  #..................................................................................
  $admin_webapps              = true,
  $admin_webapps_package_name = undef,
  $create_default_admin       = false,
  $admin_user                 = 'tomcatadmin',
  $admin_password             = 'password',
  $tomcat_users               = {},
  $tomcat_roles               = {},
  #..................................................................................
  # logging
  #..................................................................................
  $log_path                   = undef,
  $log_folder_mode            = '0660',
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
  $jrememleak_attrs           = {},
  # versionlogger
  $versionlogger_listener     = true,
  $versionlogger_logargs      = undef,
  $versionlogger_logenv       = undef,
  $versionlogger_logprops     = undef,
  # apr
  $apr_listener               = false,
  $apr_sslengine              = undef,
  # jmx
  $jmx_listener               = false,
  $jmx_registry_port          = 8050,
  $jmx_server_port            = 8051,
  $jmx_bind_address           = undef,
  $jmx_uselocalports          = undef,
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
  $ssl_sslenabledprotocols    = undef,
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
  $use_simpletcpcluster                = false,
  $cluster_membership_port             = '45565',
  $cluster_membership_bind_address     = undef, # useful if there are multiple NICs and multicast isn't using the right one
  $cluster_membership_domain           = 'tccluster',
  $cluster_receiver_address            = undef,
  $cluster_receiver_port               = '4000',
  $cluster_farm_deployer               = false,
  $cluster_parent                      = undef, # engine/host, must be 'host' if using farm deployer
  $cluster_farm_deployer_watchdir      = undef,
  $cluster_farm_deployer_deploydir     = undef, # directory not managed by this module
  $cluster_farm_deployer_watch_enabled = true,
  #..................................................................................
  # realms
  $combined_realm             = false,
  $lockout_realm              = true,
  $userdatabase_realm         = true,
  $realms                     = [],
  #..................................................................................
  # host
  $host_name                  = 'localhost',
  $host_appbase               = undef,
  $host_autodeploy            = undef,
  $host_deployonstartup       = undef,
  $host_undeployoldversions   = undef,
  $host_unpackwars            = undef,
  $host_params                = {},
  #..................................................................................
  # host contexts
  $contexts                   = [],
  #..................................................................................
  # host valves
  $singlesignon_valve         = false,
  $accesslog_valve            = true,
  $accesslog_valve_pattern    = '%h %l %u %t &quot;%r&quot; %s %b',
  $valves                     = [],
  # engine valves
  $engine_valves              = [],
  #..................................................................................
  # misc
  $globalnaming_environments  = [],
  $globalnaming_resources     = [],
  #..................................................................................
  # context configuration
  #..................................................................................
  $context_params             = {},
  $context_loader             = {},
  $context_manager            = {},
  $context_realm              = {},
  $context_resources          = {},
  $context_watchedresources   = ['WEB-INF/web.xml',"\${catalina.base}/conf/web.xml"],
  $context_parameters         = [],
  $context_environments       = [],
  $context_listeners          = [],
  $context_valves             = [],
  $context_resourcedefs       = [],
  $context_resourcelinks      = [],
  #..................................................................................
  # web apps configuration
  #..................................................................................
  # servlets
  $default_servlet_debug                = 0,
  $default_servlet_listings             = false,
  $default_servlet_gzip                 = undef,
  $default_servlet_input                = undef,
  $default_servlet_output               = undef,
  $default_servlet_readonly             = undef,
  $default_servlet_fileencoding         = undef,
  $default_servlet_showserverinfo       = undef,
  $default_servlet_params               = {},
  $jsp_servlet_checkinterval            = undef,
  $jsp_servlet_development              = undef,
  $jsp_servlet_enablepooling            = undef,
  $jsp_servlet_fork                     = false,
  $jsp_servlet_genstringaschararray     = undef,
  $jsp_servlet_javaencoding             = undef,
  $jsp_servlet_modificationtestinterval = undef,
  $jsp_servlet_trimspaces               = undef,
  $jsp_servlet_xpoweredby               = false,
  $jsp_servlet_params                   = {},
  #..................................................................................
  # servlet-mappings
  $default_servletmapping_urlpatterns   = ['/'],
  $jsp_servletmapping_urlpatterns       = ['*.jsp', '*.jspx'],
  #..................................................................................
  # session-config
  $sessionconfig_sessiontimeout         = 30,
  $sessionconfig_trackingmode           = undef,
  #..................................................................................
  # welcome-file-list
  $welcome_file_list                    = ['index.html', 'index.htm', 'index.jsp' ],
  #..................................................................................
  # security-constraint
  $security_constraints                 = [],
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
  if $install_from !~ /^(package|archive)$/ {
    fail('$install_from must be either \'package\' or \'archive\'')
  }
  if $version !~ /^([0-9]{1,2}:)?[0-9]\.[0-9]\.[0-9]{1,2}(\.M[0-9]{1,2})?(-.*)?$/ {
    fail('incorrect tomcat version number')
  }
  if $service_ensure !~ /^(stopped|running)$/ {
    fail('$service_ensure must be either \'stopped\' or \'running\'')
  }
  if $checksum_type !~ /^(none|md5|sha1|sha2|sh256|sha384|sha512)$/ {
    fail('$checksum can only be one of: none|md5|sha1|sha2|sh256|sha384|sha512')
  }
  if $checksum_verify and !$checksum {
    fail('Checksum verification requires $checksum variable to be set')
  }

  # split version string
  $array_version_full = split($version, '[-]')
  $version_real = regsubst($array_version_full[0], '[0-9]{1,2}:', '')
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
    $archive_source_real = "http://archive.apache.org/dist/tomcat/tomcat-${maj_version}/v${version_real}/bin"
  } else {
    $archive_source_real = $archive_source
  }

  if $archive_filename == undef {
    $archive_filename_real = "apache-tomcat-${version_real}.tar.gz"
  } else {
    $archive_filename_real = $archive_filename
  }

  if $extras_source == undef {
    $extras_source_real = "http://archive.apache.org/dist/tomcat/tomcat-${maj_version}/v${version_real}/bin/extras"
  } else {
    $extras_source_real = $extras_source
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

  if $package_ensure {
    if $package_ensure !~ /^(latest|present)$/ {
      fail('$package_ensure must be either \'latest\' or \'present\'')
    }
    $package_ensure_real = $package_ensure
  } else {
    $package_ensure_real = $version
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

  $notify_service = $restart_on_change ? {
    true    => Service[$service_name_real],
    default => undef
  }

  if $systemd_service_type == undef {
    if $install_from == 'archive' {
      $systemd_service_type_real = 'forking'
    } else {
      $systemd_service_type_real = 'simple'
    }
  } else {
    $systemd_service_type_real = $systemd_service_type
  }

  if $service_start == undef {
    # unused when $install_from == 'package'
    $start_cmd = $jpda_enable ? {
      true    => 'jpda start',
      default => 'start'
    }
    # catalina.sh in archive for takes -security option to enable security manager
    $security_arg = $security_manager ? {
      true    => ' -security',
      default => ''
    }
    $service_start_real = "${catalina_home_real}/bin/catalina.sh ${start_cmd}${security_arg}"
  } else {
    $service_start_real = $service_start
  }

  if $service_stop == undef {
    # unused when $install_from == 'package'
    $service_stop_real = "${catalina_home_real}/bin/catalina.sh stop"
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
    'protocol'            => $ssl_protocol,
    'executor'            => $ssl_use_threadpool ? {
      true    => $threadpool_name,
      default => undef
    },
    'connectionTimeout'   => $ssl_connectiontimeout,
    'URIEncoding'         => $ssl_uriencoding,
    'compression'         => $ssl_compression ? {
      true    => 'on',
      default => undef
    },
    'maxThreads'          => $ssl_maxthreads,
    'clientAuth'          => $ssl_clientauth,
    'sslEnabledProtocols' => $ssl_sslenabledprotocols,
    'sslProtocol'         => $ssl_sslprotocol,
    'keystoreFile'        => $ssl_keystorefile
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
    'deployOnStartup'     => $host_deployonstartup,
    'undeployOldVersions' => $host_undeployoldversions,
    'unpackWARs'          => $host_unpackwars
  }
  ), $host_params)

  $default_servlet_params_real = merge(delete_undef_values({
    'debug'          => $default_servlet_debug,
    'listings'       => $default_servlet_listings,
    'gzip'           => $default_servlet_gzip,
    'input'          => $default_servlet_input,
    'output'         => $default_servlet_output,
    'readonly'       => $default_servlet_readonly,
    'fileEncoding'   => $default_servlet_fileencoding,
    'showServerInfo' => $default_servlet_showserverinfo
  }
  ), $default_servlet_params)

  $jsp_servlet_params_real = merge(delete_undef_values({
    'checkInterval'            => $jsp_servlet_checkinterval,
    'development'              => $jsp_servlet_development,
    'enablePooling'            => $jsp_servlet_enablepooling,
    'fork'                     => $jsp_servlet_fork,
    'genStringAsCharArray'     => $jsp_servlet_genstringaschararray,
    'javaEncoding'             => $jsp_servlet_javaencoding,
    'modificationTestInterval' => $jsp_servlet_modificationtestinterval,
    'trimSpaces'               => $jsp_servlet_trimspaces,
    'xpoweredBy'               => $jsp_servlet_xpoweredby
  }
  ), $jsp_servlet_params)

  # should we force download extras libs?
  if $jmx_listener {
    $extras_enable_real = true
  } else {
    $extras_enable_real = $extras_enable
  }

  # cluster can live in engine or host, engine was original default, host is required if using farm deployer
  if $cluster_parent {
    if $cluster_parent !~ /^(engine|host)$/ {
      fail('$cluster_parent must be either \'host\' or \'engine\'')
    }
    if $cluster_farm_deployer and $cluster_parent == 'engine' {
      fail('Farm deployer cannot be used with $cluster_parent=\'engine\'')
    }
    $cluster_parent_real = $cluster_parent
  } else {
    $cluster_parent_real = $cluster_farm_deployer ? { true => 'host', default => 'engine' }
  }
  # default name for watchdir is "deploy" b/c you put WAR there to deploy it
  # deploydir (typically webapps) is where files are deployed to
  $cluster_farm_deployer_watchdir_real = pick($cluster_farm_deployer_watchdir,"${catalina_base_real}/deploy")
  $cluster_farm_deployer_deploydir_real = pick($cluster_farm_deployer_deploydir, "${catalina_base_real}/webapps")

  # start the real action
  contain tomcat::install
  contain tomcat::service
  contain tomcat::config
  Class['::tomcat::install'] -> Class['::tomcat::config'] -> Class['::tomcat::service']

  if $extras_enable_real and !$extras_package_name {
    # download and install extras from archive
    contain tomcat::extras
    Class['::tomcat::install'] -> Class['::tomcat::extras'] -> Class['::tomcat::service']
  }

  if $manage_firewall {
    contain tomcat::firewall
  }
}
