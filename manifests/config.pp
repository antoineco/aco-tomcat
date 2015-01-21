# == Class: tomcat::config
#
class tomcat::config {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }
  
  # forward variables used in templates
  $control_port = $::tomcat::control_port
  $jmx_registry_port = $::tomcat::jmx_registry_port
  $jmx_server_port = $::tomcat::jmx_server_port
  $jmx_bind_address = $::tomcat::jmx_bind_address
  $apr_sslengine = $::tomcat::apr_sslengine
  $threadpool_executor = $::tomcat::threadpool_executor
  $http_connector = $::tomcat::http_connector
  $http_port = $::tomcat::http_port
  $http_protocol = $::tomcat::http_protocol
  $http_use_threadpool = $::tomcat::http_use_threadpool
  $http_connection_timeout = $::tomcat::http_connection_timeout
  $http_uri_encoding = $::tomcat::http_uri_encoding
  $http_compression = $::tomcat::http_compression
  $http_max_threads = $::tomcat::http_max_threads
  $http_params = $::tomcat::http_params
  $ssl_connector = $::tomcat::ssl_connector
  $ssl_port = $::tomcat::ssl_port
  $ssl_protocol = $::tomcat::ssl_protocol
  $ssl_clientauth = $::tomcat::ssl_clientauth
  $ssl_sslprotocol = $::tomcat::ssl_sslprotocol
  $ssl_use_threadpool = $::tomcat::ssl_use_threadpool
  $ssl_connectiontimeout = $::tomcat::ssl_connectiontimeout
  $ssl_uriencoding = $::tomcat::ssl_uriencoding
  $ssl_compression = $::tomcat::ssl_compression
  $ssl_maxthreads = $::tomcat::ssl_maxthreads
  $ssl_keystore = $::tomcat::ssl_keystore
  $ssl_params = $::tomcat::ssl_params
  $ajp_connector = $::tomcat::ajp_connector
  $ajp_port = $::tomcat::ajp_port
  $hostname = $::tomcat::hostname
  $jvmroute = $::tomcat::jvmroute
  $autodeploy = $::tomcat::autodeploy
  $deployOnStartup = $::tomcat::deployOnStartup
  $unpackwars = $::tomcat::unpackwars
  $undeployoldversions = $::tomcat::undeployoldversions
  $use_simpletcpcluster = $::tomcat::use_simpletcpcluster
  $cluster_membership_port = $::tomcat::cluster_membership_port
  $cluster_membership_domain = $::tomcat::cluster_membership_domain
  $cluster_receiver_address = $::tomcat::cluster_receiver_address
  $lockout_realm = $::tomcat::lockout_realm
  $userdatabase_realm = $::tomcat::userdatabase_realm
  $realms = $::tomcat::realms
  $singlesignon_valve = $::tomcat::singlesignon_valve
  $accesslog_valve = $::tomcat::accesslog_valve
  $globalnaming_resources = $::tomcat::globalnaming_resources
  $instance = $::tomcat::instance
  $service_name_real = $::tomcat::service_name_real
  $java_home = $::tomcat::java_home
  $catalina_base_real = $::tomcat::catalina_base_real
  $catalina_home_real = $::tomcat::catalina_home_real
  $jasper_home_real = $::tomcat::jasper_home_real
  $catalina_tmpdir_real = $::tomcat::catalina_tmpdir_real
  $catalina_pid_real = $::tomcat::catalina_pid_real
  $java_opts_real = $::tomcat::java_opts_real
  $catalina_opts_real = $::tomcat::catalina_opts_real
  $maj_version = $::tomcat::maj_version
  $lang = $::tomcat::lang
  $security_manager_real = $::tomcat::security_manager_real
  $shutdown_wait = $::tomcat::shutdown_wait
  $shutdown_verbose = $::tomcat::shutdown_verbose
  $jpda_transport = $::tomcat::jpda_transport
  $jpda_address = $::tomcat::jpda_address
  $jpda_suspend = $::tomcat::jpda_suspend
  $jpda_opts_real = $::tomcat::jpda_opts_real
  $custom_fragment = $::tomcat::custom_fragment

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
  # - $http_protocol
  # - $http_use_threadpool
  # - $http_connection_timeout
  # - $http_uri_encoding
  # - $http_compression
  # - $http_max_threads
  # - $http_params
  # - $ssl_connector
  # - $ssl_port
  # - $ssl_protocol
  # - $ssl_clientauth
  # - $ssl_sslprotocol
  # - $ssl_use_threadpool
  # - $ssl_connectiontimeout
  # - $ssl_uriencoding
  # - $ssl_compression
  # - $ssl_maxthreads
  # - $ssl_keystore
  # - $ssl_params
  # - $ajp_connector
  # - $ajp_port
  # - $hostname
  # - $jvmroute
  # - $autodeploy
  # - $deployOnStartup
  # - $unpackwars
  # - $undeployoldversions
  # - $lockout_realm
  # - $userdatabase_realm
  # - $realms
  # - $singlesignon_valve
  # - $accesslog_valve
  # - $globalnaming_resources
  file { 'tomcat server configuration':
    path    => "${::tomcat::catalina_base_real}/conf/server.xml",
    content => template("${module_name}/common/server.xml.erb"),
    owner   => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
    mode    => '0600',
    notify  => Service[$::tomcat::service_name_real]
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
  file { 'tomcat environment variables':
    path    => $::tomcat::config_path_real,
    content => template("${module_name}/common/setenv.erb"),
    owner   => $::tomcat::tomcat_user_real,
    group   => $::tomcat::tomcat_group_real,
    mode    => '0644',
    notify  => Service[$::tomcat::service_name_real]
  }

  if $::osfamily == 'RedHat' {
    # make sure system variables are in the right place
    file { 'tomcat default variables':
      path    => "${::tomcat::catalina_base_real}/conf/${::tomcat::service_name_real}.conf",
      content => "# See ${::tomcat::config_path_real}"
    }
  }

  # generate and manage UserDatabase file
  concat { 'main UserDatabase':
    path   => "${::tomcat::catalina_base_real}/conf/tomcat-users.xml",
    owner  => $::tomcat::tomcat_user_real,
    group  => $::tomcat::tomcat_group_real,
    mode   => '0600',
    notify => Service[$::tomcat::service_name_real]
  }

  concat::fragment { 'main UserDatabase header':
    target  => 'main UserDatabase',
    content => template("${module_name}/common/UserDatabase_header.erb"),
    order   => 01
  }

  concat::fragment { 'main UserDatabase footer':
    target  => 'main UserDatabase',
    content => template("${module_name}/common/UserDatabase_footer.erb"),
    order   => 03
  }

  # configure authorized access
  unless !$::tomcat::create_default_admin {
    ::tomcat::userdb_entry { "main ${::tomcat::admin_user}":
      database => 'main UserDatabase',
      username => $::tomcat::admin_user,
      password => $::tomcat::admin_password,
      roles    => ['manager-gui', 'manager-script', 'admin-gui', 'admin-script']
    }
  }
}
