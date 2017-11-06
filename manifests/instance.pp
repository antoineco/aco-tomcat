# == Define: tomcat::instance
#
# Creates tomcat individual instances
#
# === Parameters:
#
# [*root_path*]
#   common root installation path for all instances
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
# [*service_name*]
#   tomcat service name
# [*service_ensure*]
#   whether the service should be running (valid: 'stopped'|'running')
# [*service_enable*]
#   enable service (boolean)
# [*systemd_service_type*]
#   value for systemd service type
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
# [*extras_enable*]
#   install extra libraries (boolean)
# [*extras_source*]
#   base path to tomcat extra libraries
# [*manage_firewall*]
#   manage firewall rules (boolean)
# [*checksum_verify*]
#   verify the checksum if tomcat is installed from an archive (boolean)
# [*checksum_type*]
#   archive file checksum type (valid: 'none'|'md5'|'sha1'|'sha2'|'sh256'|'sha384'|'sha512')
# [*checksum*]
#   archive file checksum
# [*admin_webapps*]
#   enable admin webapps (boolean)
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
# * Create tomcat instance
#
# === Requires:
#
# * tomcat class
#
# === Sample Usage:
#
#  tomcat::instance { 'myapp':
#    root_path           => '/home/tomcat/apps',
#    server_control_port => 9005
#  }
#
define tomcat::instance (
  $root_path                  = '/var/lib/tomcats',
  $version                    = $::tomcat::version_real,
  $archive_source             = undef,
  $archive_filename           = undef,
  $proxy_server               = undef,
  $proxy_type                 = undef,
  $service_name               = undef,
  $service_ensure             = 'running',
  $service_enable             = true,
  $restart_on_change          = $::tomcat::restart_on_change,
  $systemd_service_type       = undef,
  $service_start              = undef,
  $service_stop               = undef,
  $tomcat_user                = $::tomcat::tomcat_user_real,
  $tomcat_group               = $::tomcat::tomcat_group_real,
  $file_mode                  = '0600',
  $extras_enable              = false,
  $extras_source              = undef,
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
  $server_control_port        = 8006,
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
  $jmx_registry_port          = 8052,
  $jmx_server_port            = 8053,
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
  $http_port                  = 8081,
  $http_protocol              = undef,
  $http_use_threadpool        = false,
  $http_connectiontimeout     = undef,
  $http_uriencoding           = undef,
  $http_compression           = undef,
  $http_maxthreads            = undef,
  $http_params                = {},
  # ssl connector
  $ssl_connector              = false,
  $ssl_port                   = 8444,
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
  $ajp_port                   = 8010,
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
  # use cluster_membership_bind_address to specify which NIC is usd for multicast
  # if this causes crash, try starting tomcat without both ipv4 & ipv6, e.g. -Djava.net.preferIPv4Stack=true
  $cluster_membership_bind_address = undef,
  $cluster_membership_domain  = 'tccluster',
  $cluster_receiver_address   = undef,
  $cluster_receiver_port      = '4000',
  $cluster_farm_deployer      = false,
  #cluster_parent can be engine or host, must be host if using farm deployer
  $cluster_parent             = undef,
  $cluster_farm_deployer_watchdir  = undef,
  # This directory is currently not managed by this module
  $cluster_farm_deployer_deploydir = undef,
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
  $custom_variables           = {}) {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  # parameters validation
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

  # multi-version installation only supported with archive installation
  if $version != $::tomcat::version_real and $tomcat::install_from == 'package' {
    fail('Multi-version tomcat instances do not support \'package\' installation. Please set the value of $install_from to \'archive\'')
  }

  # split version string
  $array_version_full = split($version, '[-]')
  $version_real = regsubst($array_version_full[0], '[0-9]{1,2}:', '')
  $array_version_real = split($version_real, '[.]')
  $maj_version = $array_version_real[0]

  # -----------------------#
  # autogenerated defaults #
  # -----------------------#

  if $service_name == undef {
    $service_name_real = $::tomcat::install_from ? {
      'package' => "${::tomcat::package_name}_${name}",
      default   => "tomcat${maj_version}_${name}"
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

  if $catalina_home == undef {
    case ($version_real == $::tomcat::version_real) {
      true    : { $catalina_home_real = $::tomcat::catalina_home_real }
      default : { $catalina_home_real = "${root_path}/${name}" }
    }
  } else {
    $catalina_home_real = $catalina_home
  }

  if $catalina_base == undef {
    case ($version_real == $::tomcat::version_real) {
      true    : { $catalina_base_real = "${root_path}/${name}" }
      default : { $catalina_base_real = $catalina_home_real }
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
    case $::tomcat::install_from {
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
    case $::tomcat::install_from {
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
    case $::tomcat::install_from {
      'package' : {
        $config_path_real = $::osfamily ? {
          'Debian' => "/etc/default/${service_name_real}",
          default  => "/etc/sysconfig/${service_name_real}"
        } }
      default   : {
        $config_path_real = "${catalina_base_real}/bin/setenv.sh"
      }
    }
  } else {
    $config_path_real = $config_path
  }

  if $systemd_service_type == undef {
    if $::tomcat::install_from == 'archive' {
      $systemd_service_type_real = 'forking'
    } else {
      $systemd_service_type_real = 'simple'
    }
  } else {
    $systemd_service_type_real = $systemd_service_type
  }

  if $service_start == undef {
    case $::tomcat::install_from {
      # only used on systemd distros
      'package' : {
        if $::osfamily == 'Suse' {
          $service_start_real = '/usr/lib/tomcat/server start'
        } else {
          $service_start_real = '/usr/libexec/tomcat/server start'
        }
      }
      default   : {
        $start_cmd = $jpda_enable ? {
          true    => 'jpda start',
          default => 'start'
        }
        # catalina.sh in archive takes -security option to enable security manager
        # module currently does not put catalina.policy in ${catalina_base}/conf folder
        $security_arg = $security_manager ? {
          true    => ' -security',
          default => ''
        }
        $service_start_real = "${catalina_home_real}/bin/catalina.sh ${start_cmd}${security_arg}"
      }
    }
  } else {
    $service_start_real = $service_start
  }

  if $service_stop == undef {
    case $::tomcat::install_from {
      # only used on systemd distros
      'package' : {
        if $::osfamily == 'Suse' {
          $service_stop_real = '/usr/lib/tomcat/server stop'
        } else {
          $service_stop_real = '/usr/libexec/tomcat/server stop'
        }
      }
      default   : { $service_stop_real = "${catalina_home_real}/bin/catalina.sh stop" }
    }
  } else {
    $service_stop_real = $service_stop
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

  $notify_service = $restart_on_change ? {
    true  => Service[$service_name_real],
    false => undef
  }

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
      true    => 'tomcatThreadPool',
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
      true    => 'tomcatThreadPool',
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
      true    => 'tomcatThreadPool',
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

  # ------------------------------------#
  # installation / instance directories #
  # ------------------------------------#

  # create user if not present
  if !defined(Group[$tomcat_group]) {
    group { $tomcat_group:
      ensure => present,
      system => true
    }
  }

  if !defined(User[$tomcat_user]) {
    user { $tomcat_user:
      ensure => present,
      gid    => $tomcat_group,
      home   => $catalina_home_real,
      system => true
    }
  }

  File {
    owner => $tomcat_user,
    group => $tomcat_group,
    mode  => '0644'
  }

  Archive {
    proxy_server => $proxy_server,
    proxy_type   => $proxy_type,
    notify       => $notify_service
  }

  if !defined(File['tomcat instances root']) {
    file { 'tomcat instances root':
      ensure => directory,
      path   => $root_path
    }
  }

  # install from archive if version differs from main instance
  if $version_real != $::tomcat::version_real {
    $catalina_home_alias = $catalina_base_real ? {
      $catalina_home_real => "instance ${name} catalina_base",
      default             => undef
    }

    file { "instance ${name} catalina_home":
      ensure  => directory,
      path    => $catalina_home_real,
      require => File['tomcat instances root'],
      alias   => $catalina_home_alias
    }

    archive { "apache-tomcat-${version_real}.tar.gz":
      path            => "${catalina_home_real}/apache-tomcat-${version_real}.tar.gz",
      source          => "${archive_source_real}/${archive_filename_real}",
      cleanup         => true,
      extract         => true,
      user            => $tomcat_user,
      group           => $tomcat_group,
      checksum_verify => $checksum_verify,
      checksum_type   => $checksum_type,
      checksum        => $checksum,
      extract_path    => $catalina_home_real,
      extract_command => 'tar xf %s --strip-components=1',
      creates         => "${catalina_home_real}/LICENSE",
      require         => File["instance ${name} catalina_home"]
    }

    # ordering
    Archive["apache-tomcat-${version_real}.tar.gz"] -> File <| tag == "instance_${name}_tree" |>
  }

  # create/ensure instance directory tree
  if $catalina_base_real != $catalina_home_real {
    file {
      "instance ${name} catalina_base":
        ensure  => directory,
        path    => $catalina_base_real,
        require => File['tomcat instances root']
    }

    # ordering
    File["instance ${name} catalina_base"] -> File <| tag == "instance_${name}_tree" |>
  }

  if $log_path_real != "${catalina_base_real}/logs" {
    file { "instance ${name} logs symlink":
      ensure => link,
      path   => "${catalina_base_real}/logs",
      target => $log_path_real,
      mode   => '0777',
      force  => true,
      tag    => "instance_${name}_tree"
    }
  }

  if !defined(File[$log_path_real]) {
    file { $log_path_real:
      ensure => directory,
      path   => $log_path_real,
      mode   => $log_folder_mode,
      alias  => "instance ${name} logs directory",
      tag    => "instance_${name}_tree"
    }
  }

  file {
    "instance ${name} bin directory":
      ensure => directory,
      path   => "${catalina_base_real}/bin",
      tag    => "instance_${name}_tree";

    "instance ${name} conf directory":
      ensure => directory,
      path   => "${catalina_base_real}/conf",
      tag    => "instance_${name}_tree";

    "instance ${name} lib directory":
      ensure => directory,
      path   => "${catalina_base_real}/lib",
      tag    => "instance_${name}_tree";

    "instance ${name} webapps directory":
      ensure => directory,
      path   => "${catalina_base_real}/webapps",
      tag    => "instance_${name}_tree";

    "instance ${name} work directory":
      ensure => directory,
      path   => "${catalina_base_real}/work",
      tag    => "instance_${name}_tree";

    "instance ${name} temp directory":
      ensure => directory,
      path   => "${catalina_base_real}/temp",
      tag    => "instance_${name}_tree"
  }

  if $::osfamily == 'Debian' and $::tomcat::install_from == 'package' {
    file { "instance ${name} conf/policy.d directory":
      ensure  => directory,
      path    => "${catalina_base_real}/conf/policy.d",
      require => File["${catalina_base_real}/conf"]
    }
    file { "instance ${name} catalina.policy":
      ensure  => present,
      path    => "${catalina_base_real}/conf/policy.d/catalina.policy",
      require => File["instance ${name} conf/policy.d directory"]
    }
  }

  # default pid file directory
  if $::tomcat::install_from == 'archive' {
    file { "instance ${name} pid directory":
      ensure => directory,
      path   => "/var/run/${service_name_real}",
      owner  => $tomcat_user,
      group  => $tomcat_group
    }
  }

  # --------#
  # service #
  # --------#

  # scenarios
  # --------------------------------------------------------------------------
  #| install. | package                      | archive                        |
  #| init     |                              |                                |
  #|----------|------------------------------|--------------------------------|
  #| sysVinit | symlink to init.d script     | create init.d, use catalina.sh |
  #|----------|------------------------------|--------------------------------|
  #| systemd  | create unit, use main script | create unit, use catalina.sh   |
  # --------------------------------------------------------------------------

  if $::tomcat::params::systemd {
    # manage systemd unit on compatible systems
    # Template uses:
    # - $systemd_service_type_real
    # - $service_name_real
    # - $config_path_real
    # - $service_start_real
    # - $service_stop_real
    # - $tomcat_user
    # - $tomcat_group
    file { "${service_name_real} service unit":
      path    => "/etc/systemd/system/${service_name_real}.service",
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/instance/systemd_service_unit.erb")
    }
    # Refresh systemd configuration
    exec { "refresh ${service_name_real}":
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
      subscribe   => File["${service_name_real} service unit"],
      notify      => $notify_service
    }
  } else { # Debian, RHEL 6, SLES 11, ...
    if $::tomcat::install_from == 'package' and !$::tomcat::force_init {
      # symlink main init script
      file { "${service_name_real} service unit":
        ensure => link,
        path   => "/etc/init.d/${service_name_real}",
        owner  => 'root',
        group  => 'root',
        target => $::tomcat::service_name_real,
        notify => $notify_service
      }
    } else {
      $start_command = "/bin/su ${tomcat_user} -s /bin/bash -c '${service_start_real}'"
      $stop_command = "/bin/su ${tomcat_user} -s /bin/bash -c '${service_stop_real}'"
      $status_command = "/usr/bin/pgrep -d , -u ${tomcat_user} -G ${tomcat_group} -f Dcatalina.base=\$CATALINA_BASE"

      # create init script
      # Template uses:
      # - $catalina_base_real
      # - $start_command
      # - $stop_command
      # - $status_command
      file { "${service_name_real} service unit":
        ensure  => present,
        path    => "/etc/init.d/${service_name_real}",
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/instance/tomcat_init_generic.erb"),
        notify  => $notify_service
      }
    }
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

  service { $service_name_real:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => File["${service_name_real} service unit"];
  }

  # --------------------#
  # configuration files #
  # --------------------#

  # generate and manage server configuration
  concat { "instance ${name} server configuration":
    path    => "${catalina_base_real}/conf/server.xml",
    owner   => $tomcat_user,
    group   => $tomcat_group,
    mode    => $file_mode,
    order   => 'numeric',
    notify  => $notify_service,
    require => File["${catalina_base_real}/conf"]
  }

  # Template uses:
  # - $server_params_real
  concat::fragment { "instance ${name} server.xml header":
    order   => 0,
    content => template("${module_name}/common/server.xml/000_header.erb"),
    target  => "instance ${name} server configuration"
  }

  # Template uses:
  # - $jrememleak_attrs
  # - $jmx_listener
  # - $jmx_registry_port
  # - $jmx_server_port
  # - $jmx_bind_address
  # - $versionlogger_listener
  # - $versionlogger_logargs
  # - $versionlogger_logenv
  # - $versionlogger_logprops
  # - $apr_listener
  # - $apr_sslengine
  # - $listeners
  # - $version_real
  # - $maj_version
  concat::fragment { "instance ${name} server.xml listeners":
    order   => 10,
    content => template("${module_name}/common/server.xml/010_listeners.erb"),
    target  => "instance ${name} server configuration"
  }

  # Template uses:
  # - $userdatabase_realm
  # - $globalnaming_environments
  # - $globalnaming_resources
  if $userdatabase_realm or ($globalnaming_environments and $globalnaming_environments != []) or ($globalnaming_resources and $globalnaming_resources != []) {
    concat::fragment { "instance ${name} server.xml globalnamingresources":
      order   => 20,
      content => template("${module_name}/common/server.xml/020_globalnamingresources.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $svc_params_real
  concat::fragment { "instance ${name} server.xml service":
    order   => 30,
    content => template("${module_name}/common/server.xml/030_service.erb"),
    target  => "instance ${name} server configuration"
  }

  # Template uses:
  # - $threadpool_executor
  # - $threadpool_name
  # - $threadpool_params_real
  if $threadpool_executor {
    concat::fragment { "instance ${name} server.xml threadpool executor":
      order   => 40,
      content => template("${module_name}/common/server.xml/040_threadpool_executor.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $executors
  if $executors and $executors != [] {
    concat::fragment { "instance ${name} server.xml executors":
      order   => 41,
      content => template("${module_name}/common/server.xml/041_executors.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $http_connector
  # - $http_port
  # - $http_params_real
  # - $ssl_connector
  # - $ssl_port
  if $http_connector {
    concat::fragment { "instance ${name} server.xml http connector":
      order   => 50,
      content => template("${module_name}/common/server.xml/050_http_connector.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $ssl_connector
  # - $ssl_port
  # - $ssl_params_real
  if $ssl_connector {
    concat::fragment { "instance ${name} server.xml ssl connector":
      order   => 51,
      content => template("${module_name}/common/server.xml/051_ssl_connector.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $ajp_connector
  # - $ajp_port
  # - $ajp_protocol
  # - $ajp_params_real
  # - $ssl_connector
  # - $ssl_port
  if $ajp_connector {
    concat::fragment { "instance ${name} server.xml ajp connector":
      order   => 52,
      content => template("${module_name}/common/server.xml/052_ajp_connector.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $connectors
  if $connectors and $connectors != [] {
    concat::fragment { "instance ${name} server.xml connectors":
      order   => 53,
      content => template("${module_name}/common/server.xml/053_connectors.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $engine_params_real
  concat::fragment { "instance ${name} server.xml engine":
    order   => 60,
    content => template("${module_name}/common/server.xml/060_engine.erb"),
    target  => "instance ${name} server configuration"
  }

  # Template uses:
  # - $engine_valves
  if ($engine_valves and $engine_valves != []) {
    concat::fragment { "instance ${name} server.xml engine valves":
      order   => 65,
      content => template("${module_name}/common/server.xml/065_engine_valves.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $use_simpletcpcluster
  # - $cluster_membership_port
  # - $cluster_membership_domain
  # - $cluster_receiver_address
  if $use_simpletcpcluster {
    $cluster_order = $cluster_parent_real ? { 'host' => 95, default => 70}
    concat::fragment { "instance ${name} server.xml cluster":
      order   => $cluster_order,
      content => template("${module_name}/common/server.xml/070_cluster.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $combined_realm
  # - $lockout_realm
  # - $userdatabase_realm
  # - $realms
  if $lockout_realm or $userdatabase_realm or ($realms and $realms != []) {
    concat::fragment { "instance ${name} server.xml realms":
      order   => 80,
      content => template("${module_name}/common/server.xml/080_realms.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  # Template uses:
  # - $host_name
  # - $host_params_real
  concat::fragment { "instance ${name} server.xml host":
    order   => 90,
    content => template("${module_name}/common/server.xml/090_host.erb"),
    target  => "instance ${name} server configuration"
  }

  # Template uses:
  # - $contexts
  concat::fragment { "instance ${name} server.xml contexts":
    order   => 95,
    content => template("${module_name}/common/server.xml/095_contexts.erb"),
    target  => "instance ${name} server configuration"
  }

  # Template uses:
  # - $singlesignon_valve
  # - $accesslog_valve
  # - $accesslog_valve_pattern
  # - $valves
  # - $host_name
  # - $maj_version
  if $singlesignon_valve or $accesslog_valve or ($valves and $valves != []) {
    concat::fragment { "instance ${name} server.xml valves":
      order   => 100,
      content => template("${module_name}/common/server.xml/100_valves.erb"),
      target  => "instance ${name} server configuration"
    }
  }

  concat::fragment { "instance ${name} server.xml footer":
    order   => 200,
    content => template("${module_name}/common/server.xml/200_footer.erb"),
    target  => "instance ${name} server configuration"
  }

  # generate and manage context configuration
  ::tomcat::context { "instance ${name} default":
    path             => "${catalina_base_real}/conf/context.xml",
    owner            => $tomcat_user,
    group            => $tomcat_group,
    file_mode        => $file_mode,
    params           => $context_params,
    loader           => $context_loader,
    manager          => $context_manager,
    realm            => $context_realm,
    resources        => $context_resources,
    watchedresources => $context_watchedresources,
    parameters       => $context_parameters,
    environments     => $context_environments,
    listeners        => $context_listeners,
    valves           => $context_valves,
    resourcedefs     => $context_resourcedefs,
    resourcelinks    => $context_resourcelinks,
    require          => File["${catalina_base_real}/conf"],
    notify           => $notify_service
  }

  # generate and manage default web apps configuration
  ::tomcat::web { "instance ${name} default":
    path                               => "${catalina_base_real}/conf/web.xml",
    owner                              => $tomcat_user,
    group                              => $tomcat_group,
    file_mode                          => $file_mode,
    default_servlet_params             => $default_servlet_params_real,
    jsp_servlet_params                 => $jsp_servlet_params_real,
    default_servletmapping_urlpatterns => $default_servletmapping_urlpatterns,
    jsp_servletmapping_urlpatterns     => $jsp_servletmapping_urlpatterns,
    sessionconfig_sessiontimeout       => $sessionconfig_sessiontimeout,
    sessionconfig_trackingmode         => $sessionconfig_trackingmode,
    welcome_file_list                  => $welcome_file_list,
    version                            => $version_real,
    require                            => File["${catalina_base_real}/conf"],
    notify                             => $notify_service
  }

  # generate and manage global parameters
  # Template uses:
  # - $java_home
  # - $catalina_base_real
  # - $catalina_home_real
  # - $jasper_home_real
  # - $catalina_tmpdir_real
  # - $catalina_pid_real
  # - $java_opts_real
  # - $catalina_opts_real
  # - $tomcat_user
  # - $tomcat_group
  # - $maj_version
  # - $lang
  # - $security_manager_real
  # - $shutdown_wait
  # - $shutdown_verbose
  # - $jpda_transport
  # - $jpda_address
  # - $jpda_suspend
  # - $jpda_opts_real
  # - $custom_variables
  file { "instance ${name} environment variables":
    ensure  => present,
    path    => $config_path_real,
    content => template("${module_name}/common/setenv.erb"),
    owner   => $tomcat_user,
    group   => $tomcat_group,
    notify  => $notify_service
  }

  # ------#
  # users #
  # ------#

  # generate and manage UserDatabase file
  concat { "instance ${name} UserDatabase":
    path   => "${catalina_base_real}/conf/tomcat-users.xml",
    owner  => $tomcat_user,
    group  => $tomcat_group,
    mode   => $file_mode,
    order  => 'numeric',
    notify => $notify_service
  }

  concat::fragment { "instance ${name} UserDatabase header":
    target  => "instance ${name} UserDatabase",
    content => template("${module_name}/common/UserDatabase_header.erb"),
    order   => 1
  }

  concat::fragment { "instance ${name} UserDatabase footer":
    target  => "instance ${name} UserDatabase",
    content => template("${module_name}/common/UserDatabase_footer.erb"),
    order   => 4
  }

  # configure authorized access
  unless !$create_default_admin {
    ::tomcat::userdb_entry { "instance ${name} ${admin_user}":
      database => "instance ${name} UserDatabase",
      username => $admin_user,
      password => $admin_password,
      roles    => ['manager-gui', 'manager-script', 'admin-gui', 'admin-script']
    }

  # Configure users and roles defined in $tomcat_users and $tomcat_roles
  create_resources('::tomcat::userdb_entry', $tomcat_users, {database => "instance ${name} UserDatabase header"})
  create_resources('::tomcat::userdb_role_entry', $tomcat_roles, {database => "instance ${name} UserDatabase header"})
  }

  # --------------#
  # admin webapps #
  # --------------#

  if $admin_webapps {
    if $version_real == $::tomcat::version_real {
      # generate OS-specific variables
      case $::tomcat::install_from {
        'package' : {
          $admin_webapps_path = $::osfamily ? {
            'Debian' => "/usr/share/${::tomcat::admin_webapps_package_name_real}",
            default  => "\${catalina.home}/webapps"
          } }
        default   : {
          $admin_webapps_path = "\${catalina.home}/webapps"
        }
      }

      file { ["${catalina_base_real}/conf/Catalina","${catalina_base_real}/conf/Catalina/${host_name}"]:
        ensure => directory,
        tag    => "instance_${name}_catalina_tree"
      }

      ::tomcat::context {
        "instance ${name} manager.xml":
          path   => "${catalina_base_real}/conf/Catalina/${host_name}/manager.xml",
          params => { 'path'                => '/manager',
                      'docBase'             => "${admin_webapps_path}/manager",
                      'antiResourceLocking' => false,
                      'privileged'          => true },
          notify => $notify_service,
          tag    => "instance_${name}_admin_context";

        "instance ${name} host-manager.xml":
          path   => "${catalina_base_real}/conf/Catalina/${host_name}/host-manager.xml",
          params => { 'path'                => '/host-manager',
                      'docBase'             => "${admin_webapps_path}/host-manager",
                      'antiResourceLocking' => false,
                      'privileged'          => true },
          notify => $notify_service,
          tag    => "instance_${name}_admin_context"
      }

      # ordering
      File <| tag == "instance_${name}_catalina_tree" |>
      -> Tomcat::Context <| tag == "instance_${name}_admin_context" |>

    } else {
      # warn if admin webapps were selected for installation in a multi-version setup
      if $admin_webapps {
        warning("tomcat archives always contain admin webapps, ignoring parameter 'admin_webapps'")
      }
    }
  }

  # -------#
  # extras #
  # -------#

  if $extras_enable_real {
    # no need to duplicate libraries if enabled globally when tomcat versions are identical
    if $::tomcat::extras_enable_real and $version_real == $::tomcat::version_real {
      warning("extra libraries already enabled globally for tomcat ${version_real}, ignoring parameter 'extras_enable'")
    } else {
      Archive {
        cleanup => false,
        extract => false
      }

      archive {
        "instance ${name} catalina-jmx-remote.jar":
          path   => "${catalina_base_real}/lib/extras/catalina-jmx-remote-${version_real}.jar",
          source => "${extras_source_real}/catalina-jmx-remote.jar"
        ;

        "instance ${name} catalina-ws.jar":
          path   => "${catalina_base_real}/lib/extras/catalina-ws-${version_real}.jar",
          source => "${extras_source_real}/catalina-ws.jar"
      }

      file {
        "instance ${name} extras directory":
          ensure => directory,
          path   => "${catalina_base_real}/lib/extras";

        "instance ${name} catalina-jmx-remote.jar":
          ensure => link,
          path   => "${catalina_base_real}/lib/catalina-jmx-remote.jar",
          target => "extras/catalina-jmx-remote-${version_real}.jar";

        "instance ${name} catalina-ws.jar":
          ensure => link,
          path   => "${catalina_base_real}/lib/catalina-ws.jar",
          target => "extras/catalina-ws-${version_real}.jar";
      }
    }
  }

  # ---------#
  # firewall #
  # ---------#

  if $manage_firewall {
    # http connector
    if $http_connector {
      firewall { "${http_port} accept - tomcat (${name})":
        dport  => $http_port,
        proto  => 'tcp',
        action => 'accept'
      }
    }

    # ajp connector
    if $ajp_connector {
      firewall { "${ajp_port} accept - tomcat (${name})":
        dport  => $ajp_port,
        proto  => 'tcp',
        action => 'accept'
      }
    }

    # ssl connector
    if $ssl_connector {
      firewall { "${ssl_port} accept - tomcat (${name})":
        dport  => $ssl_port,
        proto  => 'tcp',
        action => 'accept'
      }
    }

    # jmx
    if $jmx_listener {
      firewall { "${jmx_registry_port}/${jmx_server_port} accept - tomcat (${name})":
        dport  => [$jmx_registry_port, $jmx_server_port],
        proto  => 'tcp',
        action => 'accept'
      }
    }

    #cluster
    if $use_simpletcpcluster {
      firewall { "${cluster_receiver_port} accept - tomcat (${name})":
        dport  => $cluster_receiver_port,
        proto  => 'tcp',
        action => 'accept'
      }
      firewall { "${$cluster_membership_port} accept - tomcat (${name})":
        sport       => $cluster_membership_port,
        dport       => $cluster_membership_port,
        proto       => 'udp',
        action      => 'accept',
        destination => '228.0.0.4'
      }
    }
  }
}
