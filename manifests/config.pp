# == Class: tomcat::config
#
class tomcat::config {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # generate OS-specific variables
  $config_path = $::osfamily ? {
    'RedHat' => "/etc/sysconfig/${::tomcat::service_name_real}",
    default  => "/etc/default/${::tomcat::service_name_real}"
  }

  # generate and manage log rotation
  # Template uses:
  # - $config_path
  file { 'tomcat logcron':
    path    => "/etc/cron.daily/${::tomcat::service_name_real}",
    content => template("${module_name}/common/logcron.erb"),
    mode    => '0755'
  }

  # generate and manage server configuration
  # Template uses:
  # -
  file { 'tomcat server configuration':
    path    => "${::tomcat::catalina_base_real}/conf/server.xml",
    content => template("${module_name}/common/server.xml.erb")
  }

  # generate and manage global parameters
  # Template uses:
  # -
  # note: defining the exact same parameters in two files may seem awkward,
  # but it avoids the randomness observed in some releases due to buggy startup scripts
  file {
    'tomcat environment variables':
      path    => $config_path,
      content => template("${module_name}/common/setenv.erb");

    'tomcat setenv.sh':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/bin/setenv.sh",
      target => $config_path
  }

  if $::osfamily == 'RedHat' {
    file { 'tomcat default variables':
      path    => "${::tomcat::catalina_base_real}/conf/${::tomcat::service_name_real}.conf",
      content => "# See ${$config_path}"
    }
  }

  # generate and manage UserDatabase file
  concat { 'main UserDatabase':
    path  => "${::tomcat::catalina_base_real}/conf/tomcat-users.xml",
    owner => $::tomcat::tomcat_user_real,
    group => $::tomcat::tomcat_group_real,
    mode  => '0640',
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