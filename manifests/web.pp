# == Define: tomcat::web
#
define tomcat::web (
  $path,
  $owner                              = $::tomcat::tomcat_user_real,
  $group                              = $::tomcat::tomcat_group_real,
  $file_mode                          = $::tomcat::file_mode,
  $default_servlet_params             = {},
  $jsp_servlet_params                 = {},
  $default_servletmapping_urlpatterns = [],
  $jsp_servletmapping_urlpatterns     = [],
  $sessionconfig_sessiontimeout       = undef,
  $sessionconfig_trackingmode         = undef,
  $welcome_file_list                  = [],
  $security_constraints               = [],
  $version                            = $::tomcat::version_real
  ) {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  # generate and manage context configuration
  concat { "${name} tomcat web":
    path  => $path,
    owner => $owner,
    group => $group,
    mode  => $file_mode,
    order => 'numeric'
  }

  # Template uses:
  # - $version
  concat::fragment { "${name} tomcat web header":
    order   => 0,
    content => template("${module_name}/common/web.xml/000_header.erb"),
    target  => "${name} tomcat web"
  }

  concat::fragment { "${name} tomcat web servlet title":
    order   => 010,
    content => template("${module_name}/common/web.xml/010_servlet_title.erb"),
    target  => "${name} tomcat web"
  }

  # Template uses:
  # - $default_servlet_params
  if $default_servlet_params and $default_servlet_params != {} {
    concat::fragment { "${name} tomcat web servlet default":
      order   => 011,
      content => template("${module_name}/common/web.xml/011_servlet_default.erb"),
      target  => "${name} tomcat web"
    }
  }

  # Template uses:
  # - $jsp_servlet_params
  if $jsp_servlet_params and $jsp_servlet_params != {} {
    concat::fragment { "${name} tomcat web servlet jsp":
      order   => 012,
      content => template("${module_name}/common/web.xml/012_servlet_jsp.erb"),
      target  => "${name} tomcat web"
    }
  }

  if ($default_servletmapping_urlpatterns and $default_servletmapping_urlpatterns != []) or ($jsp_servletmapping_urlpatterns and $jsp_servletmapping_urlpatterns != []) {
    concat::fragment { "${name} tomcat web servlet-mapping title":
      order   => 020,
      content => template("${module_name}/common/web.xml/020_servletmapping_title.erb"),
      target  => "${name} tomcat web"
    }
  }

  # Template uses:
  # - $default_servletmapping_urlpatterns
  if $default_servletmapping_urlpatterns and $default_servletmapping_urlpatterns != [] {
    concat::fragment { "${name} tomcat web servlet-mapping default":
      order   => 021,
      content => template("${module_name}/common/web.xml/021_servletmapping_default.erb"),
      target  => "${name} tomcat web"
    }
  }

  # Template uses:
  # - $jsp_servletmapping_urlpatterns
  if $jsp_servletmapping_urlpatterns and $jsp_servletmapping_urlpatterns != [] {
    concat::fragment { "${name} tomcat web servlet-mapping jsp":
      order   => 022,
      content => template("${module_name}/common/web.xml/022_servletmapping_jsp.erb"),
      target  => "${name} tomcat web"
    }
  }

  # TODO: enable filters configuration
  #concat::fragment { "${name} tomcat web filter":
  #  order   => 030,
  #  content => template("${module_name}/common/web.xml/030_filter.erb"),
  #  target  => "${name} tomcat web"
  #}

  # Template uses:
  # - $sessionconfig_sessiontimeout
  # - $sessionconfig_trackingmode
  if ($sessionconfig_sessiontimeout and $sessionconfig_sessiontimeout != '') or ($sessionconfig_trackingmode and $sessionconfig_trackingmode != '') {
    concat::fragment { "${name} tomcat web session-config":
      order   => 040,
      content => template("${module_name}/common/web.xml/040_sessionconfig.erb"),
      target  => "${name} tomcat web"
    }
  }

  concat::fragment { "${name} tomcat web mime-mapping":
    order   => 050,
    content => template("${module_name}/common/web.xml/050_mime_mapping.erb"),
    target  => "${name} tomcat web"
  }

  # Template uses:
  # - $welcome_file_list
  if $welcome_file_list and $welcome_file_list != [] {
    concat::fragment { "${name} tomcat web welcome-file-list":
      order   => 060,
      content => template("${module_name}/common/web.xml/060_welcome_file_list.erb"),
      target  => "${name} tomcat web"
    }
  }

  # Template uses:
  # - $security_constraints
  if $security_constraints and $security_constraints != [] {
    concat::fragment { "${name} tomcat web security-constraint":
      order   => 070,
      content => template("${module_name}/common/web.xml/070_security_constraint.erb"),
      target  => "${name} tomcat web"
    }
  }

  concat::fragment { "${name} tomcat web footer":
    order   => 200,
    content => template("${module_name}/common/web.xml/200_footer.erb"),
    target  => "${name} tomcat web"
  }
}
