# == Class: tomcat::config
#
class tomcat::config {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # generate and manage server configuration
  # Template uses:
  file { 'tomcat server configuration':
    path    => "${::tomcat::catalina_base_real}/conf/server.xml",
    content => template("${module_name}/server.xml.erb"),
    seltype => 'etc_t'
  }

  # generate and manage global parameters
  # Template uses:
  file {
    'tomcat global configuration':
      path    => "${::tomcat::catalina_base_real}/conf/${::tomcat::service_name_real}.conf",
      content => template("${module_name}/tomcat.conf.erb"),
      seltype => 'etc_t';

     # defining the exact same parameters in three different files may seem awkward,
     # but it avoids the randomness observed in some older releases due to buggy startup scripts
    'tomcat main instance configuration':
      ensure => link,
      path   => "/etc/sysconfig/${::tomcat::service_name_real}",
      target => "${::tomcat::catalina_base_real}/conf/${::tomcat::service_name_real}.conf";

    'tomcat setenv.sh':
      ensure => link,
      path   => "${::tomcat::catalina_base_real}/bin/setenv.sh",
      target => "${::tomcat::catalina_base_real}/conf/${::tomcat::service_name_real}.conf"
  }

  # generate and manage UserDatabase file
  concat { 'UserDatabase':
    path  => "${::tomcat::catalina_base_real}/conf/tomcat-users.xml",
    owner => $::tomcat::tomcat_user,
    group => $::tomcat::tomcat_user,
    mode  => '0660'
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