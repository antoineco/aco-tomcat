# == Define: tomcat::web
#
define tomcat::web (
  $path,
  $owner            = $::tomcat::tomcat_user_real,
  $group            = $::tomcat::tomcat_group_real,
  $file_mode        = $::tomcat::file_mode
  ) {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  # parameters validation
  validate_absolute_path($path)

  # generate and manage context configuration
  concat { "${name} tomcat servlet":
    path  => $path,
    owner => $owner,
    group => $group,
    mode  => $file_mode,
    order => 'numeric'
  }

  concat::fragment { "${name} tomcat servlet header":
    order   => 0,
    content => template("${module_name}/common/web.xml/000_header.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet servlet title":
    order   => 010,
    content => template("${module_name}/common/web.xml/010_servlet_title.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet servlet default":
    order   => 011,
    content => template("${module_name}/common/web.xml/011_servlet_default.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet servlet jsp":
    order   => 012,
    content => template("${module_name}/common/web.xml/012_servlet_jsp.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet servlet-mapping":
    order   => 020,
    content => template("${module_name}/common/web.xml/020_servlet_mapping.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet filter":
    order   => 030,
    content => template("${module_name}/common/web.xml/030_filter.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet session-config":
    order   => 040,
    content => template("${module_name}/common/web.xml/040_session_config.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet mime-mapping":
    order   => 050,
    content => template("${module_name}/common/web.xml/050_mime_mapping.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet welcome-file-list":
    order   => 060,
    content => template("${module_name}/common/web.xml/060_welcome_file_list.erb"),
    target  => "${name} tomcat servlet"
  }

  concat::fragment { "${name} tomcat servlet footer":
    order   => 200,
    content => template("${module_name}/common/web.xml/200_footer.erb"),
    target  => "${name} tomcat servlet"
  }
}
