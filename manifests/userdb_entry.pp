# == Define: tomcat::userdb_entry
#
define tomcat::userdb_entry (
  $password,
  $roles,
  $username = $name,
  $database = 'main UserDatabase') {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  $roles_string = join($roles, ',')

  # add formated fragment
  concat::fragment { "UserDatabase entry (${title})":
    target  => $database,
    content => template("${module_name}/common/UserDatabase_entry.erb"),
    order   => 3
  }
}
