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
      path    => "${::tomcat::catalina_base_real}/conf/${::tomcat::service_name}.conf",
      content => template("${module_name}/tomcat.conf.erb"),
      seltype => 'etc_t';

     # defining the exact same parameters in two different files may seem awkward,
     # but it avoids the randomness observed in some older releases due to buggy startup scripts
    'tomcat main instance configuration':
      path    => "/etc/sysconfig/${::tomcat::service_name}",
      content => template("${module_name}/sysconfig.erb")
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

  # make sure the tomcat user has the correct parameters
  if !defined(User[$::tomcat::tomcat_user]) {
    if $::tomcat::maj_version >= '7' {
      user { $::tomcat::tomcat_user:
        home  => $::tomcat::catalina_base_real,
        shell => '/sbin/nologin'
      }
    } else {
      user { $::tomcat::tomcat_user:
        home  => $::tomcat::catalina_base_real,
        shell => '/bin/sh'
      }
    }
  }
}