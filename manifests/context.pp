# == Define: tomcat::context
#
define tomcat::context (
  $path,
  $owner            = $::tomcat::tomcat_user_real,
  $group            = $::tomcat::tomcat_group_real,
  $file_mode        = $::tomcat::file_mode,
  $params           = {},
  $loader           = {},
  $manager          = {},
  $realm            = {},
  $resources        = {},
  $watchedresources = [],
  $parameters       = [],
  $environments     = [],
  $listeners        = [],
  $valves           = [],
  $resourcedefs     = [],
  $resourcelinks    = []
  ) {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  # generate and manage context configuration
  concat { "${name} tomcat context":
    path  => $path,
    owner => $owner,
    group => $group,
    mode  => $file_mode,
    order => 'numeric'
  }

  # Template uses:
  # - $params
  concat::fragment { "${name} tomcat context header":
    order   => 0,
    content => template("${module_name}/common/context.xml/000_header.erb"),
    target  => "${name} tomcat context"
  }

  # Template uses:
  # - $loader
  if $loader and $loader != {} {
    concat::fragment { "${name} tomcat context loader":
      order   => 010,
      content => template("${module_name}/common/context.xml/010_loader.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $manager
  if $manager and $manager != {} {
    concat::fragment { "${name} tomcat context manager":
      order   => 011,
      content => template("${module_name}/common/context.xml/011_manager.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $realm
  if $realm and $realm != {} {
    concat::fragment { "${name} tomcat context realm":
      order   => 012,
      content => template("${module_name}/common/context.xml/012_realm.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $resources
  if $resources and $resources != {} {
    concat::fragment { "${name} tomcat context resources":
      order   => 013,
      content => template("${module_name}/common/context.xml/013_resources.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $watchedresources
  if $watchedresources and $watchedresources != [] {
    concat::fragment { "${name} tomcat context watchedresources":
      order   => 014,
      content => template("${module_name}/common/context.xml/014_watchedresources.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $parameters
  if $parameters and $parameters != [] {
    concat::fragment { "${name} tomcat context parameters":
      order   => 020,
      content => template("${module_name}/common/context.xml/020_parameters.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $environments
  if $environments and $environments != [] {
    concat::fragment { "${name} tomcat context environments":
      order   => 030,
      content => template("${module_name}/common/context.xml/030_environments.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $listeners
  if $listeners and $listeners != [] {
    concat::fragment { "${name} tomcat context listeners":
      order   => 040,
      content => template("${module_name}/common/context.xml/040_listeners.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $valves
  if $valves and $valves != [] {
    concat::fragment { "${name} tomcat context valves":
      order   => 050,
      content => template("${module_name}/common/context.xml/050_valves.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $resourcedefs
  if $resourcedefs and $resourcedefs != [] {
    concat::fragment { "${name} tomcat context resourcedefs":
      order   => 060,
      content => template("${module_name}/common/context.xml/060_resourcedefs.erb"),
      target  => "${name} tomcat context"
    }
  }

  # Template uses:
  # - $resourcelinks
  if $resourcelinks and $resourcelinks != [] {
    concat::fragment { "${name} tomcat context resourcelinks":
      order   => 070,
      content => template("${module_name}/common/context.xml/070_resourcelinks.erb"),
      target  => "${name} tomcat context"
    }
  }

  concat::fragment { "${name} tomcat context footer":
    order   => 200,
    content => template("${module_name}/common/context.xml/200_footer.erb"),
    target  => "${name} tomcat context"
  }
}
