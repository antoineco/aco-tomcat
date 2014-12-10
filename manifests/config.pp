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
    content => template("${module_name}/logcron.erb")
  }

  # generate and manage server configuration
  # Template uses:
  # -
  file { 'tomcat server configuration':
    path    => "${::tomcat::catalina_base_real}/conf/server.xml",
    content => template("${module_name}/server.xml.erb"),
    seltype => 'etc_t'
  }

  # generate and manage global parameters
  # Template uses:
  # -
  # note: defining the exact same parameters in several files may seem awkward,
  # but it avoids the randomness observed in some older releases due to buggy startup scripts
  file {
    'tomcat main instance configuration':
      path    => $config_path,
      content => template("${module_name}/tomcat.conf.erb"),
      seltype => 'etc_t';

    'tomcat setenv.sh':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/bin/setenv.sh",
      target => $config_path
  }

  if $::osfamily == 'RedHat' {
    file { 'tomcat global configuration':
      ensure => link,
      path   => "${::tomcat::catalina_base_real}/conf/${::tomcat::service_name_real}.conf",
      target => $config_path
    }
  }

  # generate and manage UserDatabase file
  concat { 'UserDatabase':
    path  => "${::tomcat::catalina_base_real}/conf/tomcat-users.xml",
    owner => $::tomcat::tomcat_user_real,
    group => $::tomcat::tomcat_group_real,
    mode  => '0640',
  }

  concat::fragment { 'UserDatabase header':
    target  => 'UserDatabase',
    content => template("${module_name}/UserDatabase_header.erb"),
    order   => 01
  }

  concat::fragment { 'UserDatabase footer':
    target  => 'UserDatabase',
    content => template("${module_name}/UserDatabase_footer.erb"),
    order   => 03
  }

  # configure authorized access
  unless !$::tomcat::create_default_admin {
    ::tomcat::userdb_entry { $::tomcat::admin_user:
      username => $::tomcat::admin_user,
      password => $::tomcat::admin_password,
      roles    => ['manager-gui', 'manager-script', 'admin-gui', 'admin-script']
    }
  }
}