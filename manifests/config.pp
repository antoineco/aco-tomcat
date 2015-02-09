# == Class: tomcat::config
#
class tomcat::config {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # forward variables used in templates
  $version = $::tomcat::version
  $maj_version = $::tomcat::maj_version
  $server_params_real = $::tomcat::server_params_real
  $jmx_listener = $::tomcat::jmx_listener
  $jmx_registry_port = $::tomcat::jmx_registry_port
  $jmx_server_port = $::tomcat::jmx_server_port
  $jmx_bind_address = $::tomcat::jmx_bind_address
  $apr_listener = $::tomcat::apr_listener
  $apr_sslengine = $::tomcat::apr_sslengine
  $svc_params_real = $::tomcat::svc_params_real
  $threadpool_executor = $::tomcat::threadpool_executor
  $threadpool_name = $::tomcat::threadpool_name
  $threadpool_params_real = $::tomcat::threadpool_params_real
  $executors = $::tomcat::executors
  $http_connector = $::tomcat::http_connector
  $http_port = $::tomcat::http_port
  $http_params_real = $::tomcat::http_params_real
  $ssl_connector = $::tomcat::ssl_connector
  $ssl_port = $::tomcat::ssl_port
  $ssl_params_real = $::tomcat::ssl_params_real
  $ajp_connector = $::tomcat::ajp_connector
  $ajp_port = $::tomcat::ajp_port
  $ajp_protocol = $::tomcat::ajp_protocol
  $ajp_params_real = $::tomcat::ajp_params_real
  $connectors = $::tomcat::connectors
  $engine_params_real = $::tomcat::engine_params_real
  $host_name = $::tomcat::host_name
  $host_params_real = $::tomcat::host_params_real
  $use_simpletcpcluster = $::tomcat::use_simpletcpcluster
  $cluster_membership_port = $::tomcat::cluster_membership_port
  $cluster_membership_domain = $::tomcat::cluster_membership_domain
  $cluster_receiver_address = $::tomcat::cluster_receiver_address
  $lockout_realm = $::tomcat::lockout_realm
  $userdatabase_realm = $::tomcat::userdatabase_realm
  $realms = $::tomcat::realms
  $singlesignon_valve = $::tomcat::singlesignon_valve
  $accesslog_valve = $::tomcat::accesslog_valve
  $valves = $::tomcat::valves
  $globalnaming_resources = $::tomcat::globalnaming_resources
  $context_resources = $::tomcat::context_resources
  $java_home = $::tomcat::java_home
  $catalina_base_real = $::tomcat::catalina_base_real
  $catalina_home_real = $::tomcat::catalina_home_real
  $jasper_home_real = $::tomcat::jasper_home_real
  $catalina_tmpdir_real = $::tomcat::catalina_tmpdir_real
  $catalina_pid_real = $::tomcat::catalina_pid_real
  $java_opts_real = $::tomcat::java_opts_real
  $catalina_opts_real = $::tomcat::catalina_opts_real
  $lang = $::tomcat::lang
  $security_manager_real = $::tomcat::security_manager_real
  $shutdown_wait = $::tomcat::shutdown_wait
  $shutdown_verbose = $::tomcat::shutdown_verbose
  $jpda_transport = $::tomcat::jpda_transport
  $jpda_address = $::tomcat::jpda_address
  $jpda_suspend = $::tomcat::jpda_suspend
  $jpda_opts_real = $::tomcat::jpda_opts_real
  $custom_variables = $::tomcat::custom_variables

  # generate and manage server configuration
  concat { 'tomcat server configuration':
    path   => "${::tomcat::catalina_base_real}/conf/server.xml",
    owner  => $::tomcat::tomcat_user_real,
    group  => $::tomcat::tomcat_group_real,
    mode   => '0600',
    order  => 'numeric',
    notify => Service[$::tomcat::service_name_real]
  }

  Concat::Fragment { target  => 'tomcat server configuration' }

  # Template uses:
  # - $server_params_real
  concat::fragment { 'server.xml header':
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
  concat::fragment { 'server.xml listeners':
    order   => 10,
    content => template("${module_name}/common/server.xml/010_listeners.erb")
  }

  # Template uses:
  # - $userdatabase_realm
  # - $globalnaming_resources
  if $userdatabase_realm or ($globalnaming_resources and $globalnaming_resources != []) {
    concat::fragment { 'server.xml globalnamingresources':
      order   => 20,
      content => template("${module_name}/common/server.xml/020_globalnamingresources.erb")
    }
  }

  # Template uses:
  # - $svc_params_real
  concat::fragment { 'server.xml service':
    order   => 30,
    content => template("${module_name}/common/server.xml/030_service.erb")
  }

  # Template uses:
  # - $threadpool_executor
  # - $threadpool_name
  # - $threadpool_params_real
  if $threadpool_executor {
    concat::fragment { 'server.xml threadpool executor':
      order   => 40,
      content => template("${module_name}/common/server.xml/040_threadpool_executor.erb")
    }
  }

  # Template uses:
  # - $executors
  if $executors and $executors != [] {
    concat::fragment { 'server.xml executors':
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
    concat::fragment { 'server.xml http connector':
      order   => 50,
      content => template("${module_name}/common/server.xml/050_http_connector.erb")
    }
  }

  # Template uses:
  # - $ssl_connector
  # - $ssl_port
  # - $ssl_params_real
  if $ssl_connector {
    concat::fragment { 'server.xml ssl connector':
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
    concat::fragment { 'server.xml ajp connector':
      order   => 52,
      content => template("${module_name}/common/server.xml/052_ajp_connector.erb")
    }
  }

  # Template uses:
  # - $connectors
  if $connectors and $connectors != [] {
    concat::fragment { 'server.xml connectors':
      order   => 53,
      content => template("${module_name}/common/server.xml/053_connectors.erb")
    }
  }

  # Template uses:
  # - $engine_params_real
  concat::fragment { 'server.xml engine':
    order   => 60,
    content => template("${module_name}/common/server.xml/060_engine.erb")
  }

  # Template uses:
  # - $use_simpletcpcluster
  # - $cluster_membership_port
  # - $cluster_membership_domain
  # - $cluster_receiver_address
  if $use_simpletcpcluster {
    concat::fragment { 'server.xml cluster':
      order   => 70,
      content => template("${module_name}/common/server.xml/070_cluster.erb")
    }
  }

  # Template uses:
  # - $lockout_realm
  # - $userdatabase_realm
  # - $realms
  if $lockout_realm or $userdatabase_realm or ($realms and $realms != []) {
    concat::fragment { 'server.xml realms':
      order   => 80,
      content => template("${module_name}/common/server.xml/080_realms.erb")
    }
  }

  # Template uses:
  # - $host_name
  # - $host_params_real
  concat::fragment { 'server.xml host':
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
    concat::fragment { 'server.xml valves':
      order   => 100,
      content => template("${module_name}/common/server.xml/100_valves.erb")
    }
  }

  concat::fragment { 'server.xml footer':
    order   => 200,
    content => template("${module_name}/common/server.xml/200_footer.erb")
  }

  # generate and manage server context configuration
  # Template uses:
  # - $context_resources
  file { 'tomcat context configuration':
    path    => "${::tomcat::catalina_base_real}/conf/context.xml",
    content => template("${module_name}/common/context.xml.erb"),
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
  # - $custom_variables
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
    order  => 'numeric',
    notify => Service[$::tomcat::service_name_real]
  }

  concat::fragment { 'main UserDatabase header':
    target  => 'main UserDatabase',
    content => template("${module_name}/common/UserDatabase_header.erb"),
    order   => 1
  }

  concat::fragment { 'main UserDatabase footer':
    target  => 'main UserDatabase',
    content => template("${module_name}/common/UserDatabase_footer.erb"),
    order   => 3
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
