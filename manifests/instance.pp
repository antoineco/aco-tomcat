# == Define: tomcat::userdb_entry
#
# Creates tomcat individual instances
#
# === Parameters:
#
# [*root_path*]
#   common root installation path for all instances
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
  $root_path            = '/opt/tomcat_instances',
  $service_name         = undef,
  $service_ensure       = 'running',
  $service_enable       = true,
  $service_start        = undef,
  $service_stop         = undef,
  $enable_extras        = false,
  $manage_firewall      = false,
  #----------------------------------------------------------------------------------
  # security and administration
  #----------------------------------------------------------------------------------
  $admin_webapps        = true,
  $create_default_admin = false,
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
  $jmx_registry_port    = 8052,
  $jmx_server_port      = 8053,
  $jmx_bind_address     = '',
  #----------------------------------------------------------------------------------
  # server
  $control_port         = 8006,
  #----------------------------------------------------------------------------------
  # executor
  $threadpool_executor  = false,
  #----------------------------------------------------------------------------------
  # http connector
  $http_connector       = true,
  $http_port            = 8081,
  $use_threadpool       = false,
  #----------------------------------------------------------------------------------
  # ssl connector
  $ssl_connector        = false,
  $ssl_port             = 8444,
  #----------------------------------------------------------------------------------
  # ajp connector
  $ajp_connector        = true,
  $ajp_port             = 8010,
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
  # realms
  $lockout_realm        = true,
  $userdatabase_realm   = true,
  #----------------------------------------------------------------------------------
  # valves
  $singlesignon_valve   = false,
  $accesslog_valve      = true,
  #----------------------------------------------------------------------------------
  # server xml
  $globalnaming_resources = undef,
  #----------------------------------------------------------------------------------
  # global configuration file
  #----------------------------------------------------------------------------------
  $config_path          = undef,
  # catalina
  $catalina_home        = undef,
  $catalina_base        = undef,
  $jasper_home          = undef,
  $catalina_tmpdir      = undef,
  $catalina_pid         = undef,
  $catalina_opts        = [],
  # java
  $java_home            = undef,
  $java_opts            = ['-server'],
  # debug
  $jpda_enable          = false,
  $jpda_transport       = undef,
  $jpda_address         = undef,
  $jpda_suspend         = undef,
  $jpda_opts            = [],
  # other
  $security_manager     = false,
  $tomcat_user          = undef,
  $tomcat_group         = undef,
  $lang                 = undef,
  $shutdown_wait        = 30,
  $shutdown_verbose     = false,
  $custom_fragment      = undef) {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  # enable 'instance' context
  $instance = true

  # -----------------------#
  # autogenerated defaults #
  # -----------------------#

  if $service_name == undef {
    $service_name_real = $::tomcat::install_from ? {
      'package' => "${::tomcat::package_name}_${name}",
      default   => "${::tomcat::service_name_real}_${name}"
    } } else {
    $service_name_real = $service_name
  }

  if $catalina_home == undef {
    $catalina_home_real = $::tomcat::catalina_home_real
  } else {
    $catalina_home_real = $catalina_home
  }

  if $catalina_base == undef {
    $catalina_base_real = "${root_path}/${name}"
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
      'package' : { $catalina_pid_real = "/var/run/${service_name_real}.pid" }
      default   : { $catalina_pid_real = "${catalina_tmpdir_real}/${service_name_real}.pid" }
    }
  } else {
    $catalina_pid_real = $catalina_pid
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
      'package' : { $service_start_real = '/usr/sbin/tomcat-sysd stop' }
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
      'package' : { $service_stop_real = '/usr/sbin/tomcat-sysd stop' }
      default   : { $service_stop_real = "${catalina_home_real}/bin/catalina.sh stop" }
    }
  } else {
    $service_stop_real = $service_stop
  }

  $java_opts_real = join($java_opts, ' ')
  $catalina_opts_real = join($catalina_opts, ' ')
  $jpda_opts_real = join($jpda_opts, ' ')

  if $::osfamily == 'Debian' {
    $security_manager_real = $security_manager ? {
      true    => 'yes',
      default => 'no'
    } } else {
    $security_manager_real = $security_manager
  }

  # should we force download extras libs?
  if ($log4j_enable or $jmx_listener) and !$::tomcat::enable_extras_real {
    $enable_extras_real = true
  } else {
    $enable_extras_real = $enable_extras
  }

  # --------#
  # service #
  # --------#

  if $::operatingsystem == 'OpenSuSE' {
    Service { # not explicit on OpenSuSE
      provider => systemd }
  }

  case $::tomcat::install_from {
    'package' : {
      # manage startup script/unit
      if $::osfamily == 'Debian' and $::tomcat::maj_version > 6 {
        file { "${service_name_real} service unit":
          path    => "/etc/init.d/${service_name_real}",
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content => template("${module_name}/instance/tomcat${::tomcat::maj_version}_init_deb.erb");
        }
      } elsif $::operatingsystem == 'OpenSuSE' {
        file { "${service_name_real} service unit":
          path    => "/usr/lib/systemd/system/${service_name_real}.service",
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/instance/systemd_unit_suse.erb")
        }
      } elsif $::operatingsystem == 'Fedora' or ($::osfamily == 'RedHat' and $::operatingsystem != 'Fedora' and $::operatingsystemmajrelease >= 7) {
        file { "${service_name_real} service unit":
          path    => "/usr/lib/systemd/system/${service_name_real}.service",
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/instance/systemd_unit_rhel.erb")
        }
      } else {
        file { "${service_name_real} service unit":
          ensure => link,
          path   => "/etc/init.d/${service_name_real}",
          owner  => 'root',
          group  => 'root',
          target => $::tomcat::service_name_real
        }
      }

      service { $service_name_real:
        ensure  => $service_ensure,
        enable  => $service_enable,
        require => File["${service_name_real} service unit"]
      }
    }
    # archive
    default   : {
      # systemd is prefered if supported
      if $::tomcat::params::systemd {
        if $::operatingsystem == 'OpenSuSE' {
          file { "${service_name_real} service unit":
            path    => "/usr/lib/systemd/system/${service_name_real}.service",
            owner   => 'root',
            group   => 'root',
            content => template("${module_name}/instance/systemd_unit_suse.erb")
          }
        } else { # RHEL 7+ or Fedora
          file { "${service_name_real} service unit":
            path    => "/usr/lib/systemd/system/${service_name_real}.service",
            owner   => 'root',
            group   => 'root',
            content => template("${module_name}/instance/systemd_unit_rhel.erb")
          }
        }

        service { $service_name_real:
          ensure  => $service_ensure,
          enable  => $service_enable,
          require => File["${service_name_real} service unit"];
        }
        # temporary solution until a proper init script is included
      } else {
        $start_command = $jpda_enable ? {
          true    => "export CATALINA_BASE=${catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${catalina_home_real}/bin/catalina.sh jpda start'",
          default => "export CATALINA_BASE=${catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${catalina_home_real}/bin/catalina.sh start'"
        }
        $stop_command = "export CATALINA_BASE=${catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${catalina_home_real}/bin/catalina.sh jpda stop'"
        $status_command = "/usr/bin/pgrep -d , -u ${::tomcat::tomcat_user_real} -G ${::tomcat::tomcat_group_real} -f Dcatalina.base=${catalina_base_real}"

        # generate tomcat service
        service { $service_name_real:
          ensure   => $service_ensure,
          enable   => $service_enable,
          provider => base,
          start    => $start_command,
          stop     => $stop_command,
          status   => $status_command
        }
      }
    }
  }

  # ---------------------#
  # instance directories #
  # ---------------------#

  File {
    owner   => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
    mode    => '0660',
    require => Class['::tomcat::install']
  }

  if !defined(File['tomcat instances root']) {
    file { 'tomcat instances root':
      ensure => directory,
      path   => $root_path
    }
  }

  file {
    "instance ${name} catalina_base":
      ensure  => directory,
      path    => $catalina_base_real,
      require => File['tomcat instances root'];

    "instance ${name} logs directory":
      ensure => directory,
      path   => "/var/log/${service_name_real}"
  } ->
  file {
    "instance ${name} bin directory":
      ensure => directory,
      path   => "${catalina_base_real}/bin";

    "instance ${name} conf directory":
      ensure => directory,
      path   => "${catalina_base_real}/conf";

    "instance ${name} lib directory":
      ensure => directory,
      path   => "${catalina_base_real}/lib";

    "instance ${name} logs symlink":
      ensure => link,
      path   => "${catalina_base_real}/logs",
      target => "/var/log/${service_name_real}";

    "instance ${name} webapps directory":
      ensure => directory,
      path   => "${catalina_base_real}/webapps";

    "instance ${name} work directory":
      ensure => directory,
      path   => "${catalina_base_real}/work";

    "instance ${name} temp directory":
      ensure => directory,
      path   => "${catalina_base_real}/temp"
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

  # --------------------#
  # configuration files #
  # --------------------#

  # generate and manage server configuration
  # Template uses:
  # - $control_port
  # - $jmx_registry_port
  # - $jmx_server_port
  # - $jmx_bind_address
  # - $apr_sslengine
  # - $threadpool_executor
  # - $http_connector
  # - $http_port
  # - $use_threadpool
  # - $ssl_connector
  # - $ssl_port
  # - $ajp_connector
  # - $ajp_port
  # - $hostname
  # - $jvmroute
  # - $autodeploy
  # - $deployOnStartup
  # - $unpackwars
  # - $undeployoldversions
  # - $singlesignon_valve
  # - $accesslog_valve
  # - $lockout_realm
  # - $userdatabase_realm
  file { "instance ${name} server configuration":
    path    => "${catalina_base_real}/conf/server.xml",
    content => template("${module_name}/common/server.xml.erb"),
    owner   => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
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
  # - $custom_fragment
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
    notify => Service[$service_name_real]
  }

  concat::fragment { "instance ${name} UserDatabase header":
    target  => "instance ${name} UserDatabase",
    content => template("${module_name}/common/UserDatabase_header.erb"),
    order   => 01
  }

  concat::fragment { "instance ${name} UserDatabase footer":
    target  => "instance ${name} UserDatabase",
    content => template("${module_name}/common/UserDatabase_footer.erb"),
    order   => 03
  }

  # configure authorized access
  unless !$create_default_admin {
    ::tomcat::userdb_entry { "instance ${name} ${::tomcat::admin_user}":
      database => "instance ${name} UserDatabase",
      username => $admin_user,
      password => $admin_password,
      roles    => ['manager-gui', 'manager-script', 'admin-gui', 'admin-script']
    }
  }

  # --------------#
  # admin webapps #
  # --------------#

  if $admin_webapps { # generate OS-specific variables
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
    file { "instance ${name} Catalina/${hostname} dir":
      ensure => directory,
      path   => "${catalina_base_real}/conf/Catalina/${hostname}"
    } ->
    file {
      "instance ${name} manager.xml":
        path    => "${catalina_base_real}/conf/Catalina/${hostname}/manager.xml",
        content => template("${module_name}/instance/manager.xml.erb");

      "instance ${name} host-manager.xml":
        path    => "${catalina_base_real}/conf/Catalina/${hostname}/host-manager.xml",
        content => template("${module_name}/instance/host-manager.xml.erb")
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
