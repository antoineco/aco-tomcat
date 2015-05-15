# == Define: tomcat::instance
#
# Creates tomcat individual instances
#
# === Parameters:
#
# [*root_path*]
#   common root installation path for all instances
# [*version*]
#   tomcat full version number (valid format: x.y.z)
# [*archive_source*]
#   where to download archive from (only if installed from archive)
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
# [*enable_extras*]
#   install extra libraries (boolean)
# [*manage_firewall*]
#   manage firewall rules (boolean)
# [*admin_webapps*]
#   enable admin webapps (boolean)
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
# * Create tomcat instance
#
# === Requires:
#
# * tomcat class
#
# === Sample Usage:
#
#  ::tomcat::instance { 'myapp':
#    root_path    => '/home/tomcat/apps',
#    control_port => 9005
#  }
#
define tomcat::instance (
  $root_path                  = '/var/lib/tomcats',
  $version                    = $::tomcat::version,
  $archive_source             = undef,
  $service_name               = undef,
  $service_ensure             = 'running',
  $service_enable             = true,
  $service_start              = undef,
  $service_stop               = undef,
  $enable_extras              = false,
  $manage_firewall            = false,
  #..................................................................................
  # security and administration
  #..................................................................................
  $admin_webapps              = true,
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
  $server_control_port        = 8006,
  $server_shutdown            = 'SHUTDOWN',
  $server_address             = undef,
  $server_params              = {},
  #..................................................................................
  # listeners
  $apr_listener               = false,
  $apr_sslengine              = undef,
  # jmx
  $jmx_listener               = false,
  $jmx_registry_port          = 8052,
  $jmx_server_port            = 8053,
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
  $context_resources          = [],
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
  require ::tomcat::install

  # parameters validation
  validate_re($version, '^[0-9]|[0-9]u[0-9]{1,2}$', 'incorrect tomcat version number')
  validate_re($service_ensure, '^(stopped|running)$', '$service_ensure must be either \'stopped\', or \'running\'')
  validate_array($listeners, $executors, $connectors, $realms, $valves, $globalnaming_resources, $context_resources, $catalina_opts, $java_opts, $jpda_opts)
  validate_hash($server_params, $svc_params, $threadpool_params, $http_params, $ssl_params, $ajp_params, $engine_params, $host_params, $custom_variables)

  # multi-version installation only supported with archive installation
  if $version != $::tomcat::version and $tomcat::install_from == 'package' {
    fail('Multi-version tomcat instances do not support \'package\' installation. Please set the value of $install_from to \'archive\'')
  }

  # get major version
  $array_version = split($version, '[.]')
  $maj_version = $array_version[0]

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
    $archive_source_real = "http://archive.apache.org/dist/tomcat/tomcat-${maj_version}/v${version}/bin/apache-tomcat-${version}.tar.gz"
  } else {
    $archive_source_real = $archive_source
  }

  if $catalina_home == undef {
    case ($version == $::tomcat::version) {
      true    : { $catalina_home_real = $::tomcat::catalina_home_real }
      default : { $catalina_home_real = "${root_path}/${name}" }
    }
  } else {
    $catalina_home_real = $catalina_home
  }

  if $catalina_base == undef {
    case ($version == $::tomcat::version) {
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
    $catalina_pid_real = "/var/run/${service_name_real}.pid"
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

  if $service_start == undef {
    case $::tomcat::install_from {
      'package' : {
        if $::operatingsystem == 'Fedora' and $::operatingsystemmajrelease >= '20' {
          $service_start_real = '/usr/libexec/tomcat/server start'
        }
        else {
          $service_start_real = '/usr/sbin/tomcat-sysd start'
        }
      }
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
    case $::tomcat::install_from {
      'package' : {
        if $::operatingsystem == 'Fedora' and $::operatingsystemmajrelease >= '20' {
          $service_stop_real = '/usr/libexec/tomcat/server stop'
        }
        else {
          $service_stop_real = '/usr/sbin/tomcat-sysd stop'
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
    'protocol'          => $ssl_protocol,
    'executor'          => $ssl_use_threadpool ? {
      true    => 'tomcatThreadPool',
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
    'deployOnStartup'     => $host_deployOnStartup,
    'undeployOldVersions' => $host_undeployoldversions,
    'unpackWARs'          => $host_unpackwars
  }
  ), $host_params)

  # should we force download extras libs?
  if ($log4j_enable or $jmx_listener) and !$::tomcat::enable_extras_real {
    $enable_extras_real = true
  } else {
    $enable_extras_real = $enable_extras
  }

  # ------------------------------------#
  # installation / instance directories #
  # ------------------------------------#

  File {
    owner   => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
    mode    => '0644'
  }

  if !defined(File['tomcat instances root']) {
    file { 'tomcat instances root':
      ensure => directory,
      path   => $root_path
    }
  }

  # install from archive if version differs from main instance
  if $version != $::tomcat::version {
    $catalina_home_alias = $catalina_base_real ? {
      $catalina_home_real => "instance ${name} catalina_base",
      default             => undef
    }

    file { "instance ${name} catalina_home":
      ensure  => directory,
      path    => $catalina_home_real,
      require => File['tomcat instances root'],
      alias   => $catalina_home_alias
    } ->
    staging::file { "apache-tomcat-${version}.tar.gz": source => $archive_source_real } ->
    staging::extract { "apache-tomcat-${version}.tar.gz":
      target  => $catalina_home_real,
      creates => "${catalina_home_real}/bin",
      user    => $::tomcat::tomcat_user_real,
      group   => $::tomcat::tomcat_group_real,
      strip   => 1
    }

    # ordering
    Staging::Extract <| title == "apache-tomcat-${version}.tar.gz" |> -> File <| tag == "instance_${name}_tree" |>
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
      mode   => '0660',
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
    } ->
    file { "instance ${name} catalina.policy":
      ensure => present,
      path   => "${catalina_base_real}/conf/policy.d/catalina.policy"
    }
  }

  # pid file management
  if $::tomcat::install_from == 'archive' {
    file { "instance ${name} pid file":
      ensure => present,
      path   => $catalina_pid_real
    }
  }

  # --------#
  # service #
  # --------#

  if $::operatingsystem == 'OpenSuSE' {
    Service {
      provider => systemd # not explicit on OpenSuSE
    }
  }

  if $::tomcat::params::systemd {
    # manage systemd unit on compatible systems
    if $::osfamily == 'Suse' { # SuSE
      file { "${service_name_real} service unit":
        path    => "/usr/lib/systemd/system/${service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_suse.erb")
      }
    } elsif $::operatingsystem == 'Fedora' and $::operatingsystemmajrelease >= '20' { # Fedora 20+
      file { "${service_name_real} service unit":
        path    => "/usr/lib/systemd/system/${service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_fedora.erb")
      }
    } else { # RHEL 7+ or Fedora 17-19
      file { "${service_name_real} service unit":
        path    => "/usr/lib/systemd/system/${service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_rhel.erb")
      }
    }
  } else { # Debian/Ubuntu, RHEL 6, SLES 11, ...
    case $::tomcat::install_from {
      'package' : {
        # symlink main init script
        file { "${service_name_real} service unit":
          ensure => link,
          path   => "/etc/init.d/${service_name_real}",
          owner  => 'root',
          group  => 'root',
          target => $::tomcat::service_name_real
        }
      }
      default   : {
        $start_command = "export CATALINA_BASE=${catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${service_start_real}'"
        $stop_command = "export CATALINA_BASE=${catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${service_stop_real}'"
        $status_command = "/usr/bin/pgrep -d , -u ${::tomcat::tomcat_user_real} -G ${::tomcat::tomcat_group_real} -f Dcatalina.base=${catalina_base_real}"

        # create init script
        file { "${service_name_real} service unit":
          ensure  => 'file',
          path    => "/etc/init.d/${service_name_real}",
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content => template("${module_name}/instance/tomcat_init_generic.erb")
        }
      }
    }
  }

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
    path   => "${catalina_base_real}/conf/server.xml",
    owner  => $::tomcat::tomcat_user_real,
    group  => $::tomcat::tomcat_group_real,
    mode   => '0600',
    order  => 'numeric',
    notify => Service[$service_name_real]
  }

  Concat::Fragment { target  => "instance ${name} server configuration" }

  # Template uses:
  # - $server_params_real
  concat::fragment { "instance ${name} server.xml header":
    order   => 0,
    content => template("${module_name}/common/server.xml/000_header.erb")
  }

  # Template uses:
  # - $jmx_listener
  # - $jmx_registry_port
  # - $jmx_server_port
  # - $jmx_bind_address
  # - $apr_listener
  # - $apr_sslengine
  # - $listeners
  # - $version
  # - $maj_version
  concat::fragment { "instance ${name} server.xml listeners":
    order   => 10,
    content => template("${module_name}/common/server.xml/010_listeners.erb")
  }

  # Template uses:
  # - $userdatabase_realm
  # - $globalnaming_resources
  if $userdatabase_realm or ($globalnaming_resources and $globalnaming_resources != []) {
    concat::fragment { "instance ${name} server.xml globalnamingresources":
      order   => 20,
      content => template("${module_name}/common/server.xml/020_globalnamingresources.erb")
    }
  }

  # Template uses:
  # - $svc_params_real
  concat::fragment { "instance ${name} server.xml service":
    order   => 30,
    content => template("${module_name}/common/server.xml/030_service.erb")
  }

  # Template uses:
  # - $threadpool_executor
  # - $threadpool_name
  # - $threadpool_params_real
  if $threadpool_executor {
    concat::fragment { "instance ${name} server.xml threadpool executor":
      order   => 40,
      content => template("${module_name}/common/server.xml/040_threadpool_executor.erb")
    }
  }

  # Template uses:
  # - $executors
  if $executors and $executors != [] {
    concat::fragment { "instance ${name} server.xml executors":
      order   => 41,
      content => template("${module_name}/common/server.xml/041_executors.erb")
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
      content => template("${module_name}/common/server.xml/050_http_connector.erb")
    }
  }

  # Template uses:
  # - $ssl_connector
  # - $ssl_port
  # - $ssl_params_real
  if $ssl_connector {
    concat::fragment { "instance ${name} server.xml ssl connector":
      order   => 51,
      content => template("${module_name}/common/server.xml/051_ssl_connector.erb")
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
      content => template("${module_name}/common/server.xml/052_ajp_connector.erb")
    }
  }

  # Template uses:
  # - $connectors
  if $connectors and $connectors != [] {
    concat::fragment { "instance ${name} server.xml connectors":
      order   => 53,
      content => template("${module_name}/common/server.xml/053_connectors.erb")
    }
  }

  # Template uses:
  # - $engine_params_real
  concat::fragment { "instance ${name} server.xml engine":
    order   => 60,
    content => template("${module_name}/common/server.xml/060_engine.erb")
  }

  # Template uses:
  # - $use_simpletcpcluster
  # - $cluster_membership_port
  # - $cluster_membership_domain
  # - $cluster_receiver_address
  if $use_simpletcpcluster {
    concat::fragment { "instance ${name} server.xml cluster":
      order   => 70,
      content => template("${module_name}/common/server.xml/070_cluster.erb")
    }
  }

  # Template uses:
  # - $lockout_realm
  # - $userdatabase_realm
  # - $realms
  if $lockout_realm or $userdatabase_realm or ($realms and $realms != []) {
    concat::fragment { "instance ${name} server.xml realms":
      order   => 80,
      content => template("${module_name}/common/server.xml/080_realms.erb")
    }
  }

  # Template uses:
  # - $host_name
  # - $host_params_real
  concat::fragment { "instance ${name} server.xml host":
    order   => 90,
    content => template("${module_name}/common/server.xml/090_host.erb")
  }

  # Template uses:
  # - $singlesignon_valve
  # - $accesslog_valve
  # - $valves
  # - $host_name
  # - $maj_version
  if $singlesignon_valve or $accesslog_valve or ($valves and $valves != []) {
    concat::fragment { "instance ${name} server.xml valves":
      order   => 100,
      content => template("${module_name}/common/server.xml/100_valves.erb")
    }
  }

  concat::fragment { "instance ${name} server.xml footer":
    order   => 200,
    content => template("${module_name}/common/server.xml/200_footer.erb")
  }

  # generate and manage server context configuration
  # Template uses:
  # - $context_resources
  file { "instance ${name} context configuration":
    file    => 'file',
    path    => "${catalina_base_real}/conf/context.xml",
    content => template("${module_name}/common/context.xml.erb"),
    owner   => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
    mode    => '0600',
    notify  => Service[$service_name_real]
  }

  # generate and manage global parameters
  # Template uses:
  # - $instance
  # - $service_name_real
  # - $java_home
  # - $catalina_base_real
  # - $catalina_home_real
  # - $jasper_home_real
  # - $catalina_tmpdir_real
  # - $catalina_pid_real
  # - $java_opts_real
  # - $catalina_opts_real
  # - $tomcat::tomcat_user_real
  # - $tomcat::tomcat_group_real
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
    path    => $config_path_real,
    content => template("${module_name}/common/setenv.erb"),
    owner   => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
    notify  => Service[$service_name_real]
  }

  # ------#
  # users #
  # ------#

  # generate and manage UserDatabase file
  concat { "instance ${name} UserDatabase":
    path   => "${catalina_base_real}/conf/tomcat-users.xml",
    owner  => $::tomcat::tomcat_user_real,
    group  => $::tomcat::tomcat_group_real,
    mode   => '0600',
    order  => 'numeric',
    notify => Service[$service_name_real]
  }

  concat::fragment { "instance ${name} UserDatabase header":
    target  => "instance ${name} UserDatabase",
    content => template("${module_name}/common/UserDatabase_header.erb"),
    order   => 1
  }

  concat::fragment { "instance ${name} UserDatabase footer":
    target  => "instance ${name} UserDatabase",
    content => template("${module_name}/common/UserDatabase_footer.erb"),
    order   => 3
  }

  # configure authorized access
  unless !$create_default_admin {
    ::tomcat::userdb_entry { "instance ${name} ${admin_user}":
      database => "instance ${name} UserDatabase",
      username => $admin_user,
      password => $admin_password,
      roles    => ['manager-gui', 'manager-script', 'admin-gui', 'admin-script']
    }
  }

  # --------------#
  # admin webapps #
  # --------------#

  if $admin_webapps {
    if $version == $::tomcat::version {
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

      file { "instance ${name} Catalina dir":
        ensure  => directory,
        path    => "${catalina_base_real}/conf/Catalina",
        require => File["${catalina_base_real}/conf"]
      } ->
      file { "instance ${name} Catalina/${host_name} dir":
        ensure => directory,
        path   => "${catalina_base_real}/conf/Catalina/${host_name}"
      } ->
      file {
        "instance ${name} manager.xml":
          path    => "${catalina_base_real}/conf/Catalina/${host_name}/manager.xml",
          content => template("${module_name}/instance/manager.xml.erb");

        "instance ${name} host-manager.xml":
          path    => "${catalina_base_real}/conf/Catalina/${host_name}/host-manager.xml",
          content => template("${module_name}/instance/host-manager.xml.erb")
      }
    } else {
      # warn if admin webapps were selected for installation
      if $admin_webapps {
        warning("tomcat archives always contain admin webapps, ignoring parameter 'admin_webapps'")
      }
    }
  }

  # --------#
  # logging #
  # --------#

  if $log4j_enable {
    # warn user if log4j is not installed
    unless $::tomcat::log4j {
      warning("instance ${name}: logging with log4j will not work unless the log4j library is installed")
    }

    # no need to duplicate libraries if enabled globally
    if $::tomcat::log4j_enable {
      warning("instance ${name}: log4j is already enabled globally, ignoring parameter 'log4j_enable'")
    } else {
      # generate OS-specific variables
      $log4j_path = $::osfamily ? {
        'Debian' => '/usr/share/java/log4j-1.2.jar',
        default  => '/usr/share/java/log4j.jar'
      }

      file { "instance ${name} log4j library":
        ensure => link,
        path   => "${catalina_base_real}/lib/log4j.jar",
        target => $log4j_path,
        notify => Service[$service_name_real]
      }
    }

    if $log4j_conf_type == 'xml' {
      file {
        "instance ${name} log4j xml configuration":
          ensure => present,
          path   => "${catalina_base_real}/lib/log4j.xml",
          source => $log4j_conf_source,
          notify => Service[$service_name_real];

        "instance ${name} log4j ini configuration":
          ensure => absent,
          path   => "${catalina_base_real}/lib/log4j.properties";

        "instance ${name} log4j dtd file":
          ensure => present,
          path   => "${catalina_base_real}/lib/log4j.dtd",
          source => "puppet:///modules/${module_name}/log4j/log4j.dtd"
      }
    } else {
      file {
        "instance ${name} log4j ini configuration":
          ensure => present,
          path   => "${catalina_base_real}/lib/log4j.properties",
          source => $log4j_conf_source,
          notify => Service[$service_name_real];

        "instance ${name} log4j xml configuration":
          ensure => absent,
          path   => "${catalina_base_real}/lib/log4j.xml";

        "instance ${name} log4j dtd file":
          ensure => absent,
          path   => "${catalina_base_real}/lib/log4j.dtd"
      }
    }

    file { "instance ${name} logging configuration":
      ensure => absent,
      path   => "${catalina_base_real}/conf/logging.properties",
      backup => true
    }
  }

  # -------#
  # extras #
  # -------#

  if $enable_extras_real {
    if $::tomcat::enable_extras_real { # no need to duplicate libraries if enabled globally
      warning('extra libraries already enabled globally, ignoring parameter \'enable_extras\'')
    } else {
      Staging::File {
        require => File["instance ${name} extras directory"],
        notify  => Service[$service_name_real]
      }

      staging::file {
        "instance ${name} catalina-jmx-remote.jar":
          target => "${catalina_base_real}/lib/extras/catalina-jmx-remote-${::tomcat::version}.jar",
          source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-jmx-remote.jar"
        ;

        "instance ${name} catalina-ws.jar":
          target => "${catalina_base_real}/lib/extras/catalina-ws-${::tomcat::version}.jar",
          source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-ws.jar"
        ;

        "instance ${name} tomcat-juli-adapters.jar":
          target => "${catalina_base_real}/lib/extras/tomcat-juli-adapters-${::tomcat::version}.jar",
          source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli-adapters.jar"
        ;

        "instance ${name} tomcat-juli-extras.jar":
          target => "${catalina_base_real}/lib/extras/tomcat-juli-extras-${::tomcat::version}.jar",
          source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli.jar"
      }

      file {
        "instance ${name} extras directory":
          ensure => directory,
          path   => "${catalina_base_real}/lib/extras";

        "instance ${name} tomcat-juli.jar":
          ensure => link,
          path   => "${catalina_base_real}/bin/tomcat-juli.jar",
          target => "${catalina_base_real}/lib/tomcat-juli-extras.jar";

        "instance ${name} catalina-jmx-remote.jar":
          ensure => link,
          path   => "${catalina_base_real}/lib/catalina-jmx-remote.jar",
          target => "extras/catalina-jmx-remote-${::tomcat::version}.jar";

        "instance ${name} catalina-ws.jar":
          ensure => link,
          path   => "${catalina_base_real}/lib/catalina-ws.jar",
          target => "extras/catalina-ws-${::tomcat::version}.jar";

        "instance ${name} tomcat-juli-adapters.jar":
          ensure => link,
          path   => "${catalina_base_real}/lib/tomcat-juli-adapters.jar",
          target => "extras/tomcat-juli-adapters-${::tomcat::version}.jar";

        "instance ${name} tomcat-juli-extras.jar":
          ensure => link,
          path   => "${catalina_base_real}/lib/tomcat-juli-extras.jar",
          target => "extras/tomcat-juli-extras-${::tomcat::version}.jar"
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
        port   => $http_port,
        proto  => 'tcp',
        action => 'accept'
      }
    }

    # ajp connector
    if $ajp_connector {
      firewall { "${ajp_port} accept - tomcat (${name})":
        port   => $ajp_port,
        proto  => 'tcp',
        action => 'accept'
      }
    }

    # ssl connector
    if $ssl_connector {
      firewall { "${ssl_port} accept - tomcat (${name})":
        port   => $ssl_port,
        proto  => 'tcp',
        action => 'accept'
      }
    }

    # jmx
    if $jmx_listener {
      firewall { "${jmx_registry_port}/${jmx_server_port} accept - tomcat (${name})":
        port   => [$jmx_registry_port, $jmx_server_port],
        proto  => 'tcp',
        action => 'accept'
      }
    }
  }
}
