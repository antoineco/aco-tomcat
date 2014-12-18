# == Class: tomcat::config
#
class tomcat::config {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # generate and manage server configuration
  # Template uses:
  # -
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
  # -
  # note: defining the exact same parameters in two files may seem awkward,
  # but it avoids the randomness observed in some releases due to buggy startup scripts
  file {
    'tomcat environment variables':
      path    => $::tomcat::config_path_real,
      content => template("${module_name}/common/setenv.erb"),
      owner   => $::tomcat::tomcat_user_real,
      group   => $::tomcat::tomcat_group_real,
      mode    => '0644',
      notify  => Service[$::tomcat::service_name_real]
  }

  if $::osfamily == 'RedHat' {
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