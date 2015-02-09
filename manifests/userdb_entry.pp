# == Define: tomcat::userdb_entry
#
define tomcat::userdb_entry (
  $username,
  $password,
  $roles,
  $database = 'main UserDatabase') {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  # parameters validation
  validate_array($roles)
  validate_string($username, $password)

  $roles_string = join($roles, ',')

  # add formated fragment
  concat::fragment { "UserDatabase entry (${title})":
    target  => $database,
    content => template("${module_name}/common/UserDatabase_entry.erb"),
    order   => 2
  }
}