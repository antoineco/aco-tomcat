define tomcat::userdb_entry (
  $add_roles = 'false',
  $username = undef,
  $password = undef,
  $roles,
  $database = 'main UserDatabase') {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  if $add_roles == 'true' {
    validate_array($roles)
    concat::fragment { "UserDatabase entry (${title})":
      target  => $database,
      content => template("${module_name}/common/UserDatabase_role_entry.erb"),
      order   => 2
    }
  }
  elsif $add_roles == 'false' {
    validate_array($roles)
    validate_string($username, $password)
    $roles_string = join($roles, ',')
    concat::fragment { "UserDatabase entry (${title})":
    target  => $database,
    content => template("${module_name}/common/UserDatabase_entry.erb"),
    order   => 3
    }
  }
}