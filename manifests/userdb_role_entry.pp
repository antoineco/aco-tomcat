# == Define: tomcat::userdb_role_entry
#
define tomcat::userdb_role_entry (
  $rolename = $name,
  $database = 'main UserDatabase') {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  # add formated fragment
  concat::fragment { "UserDatabase entry (${title})":
    target  => $database,
    content => template("${module_name}/common/UserDatabase_role_entry.erb"),
    order   => 2
  }
}
