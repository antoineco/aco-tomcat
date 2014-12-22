# == Class: tomcat::service::archive
#
# This class configures the tomcat service when installed from archive
#
class tomcat::service::archive {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # systemd is prefered if supported
  if $::tomcat::params::systemd {
    if $::operatingsystem == 'OpenSuSE' {
      file { "${::tomcat::service_name_real} service unit":
        path    => "/usr/lib/systemd/system/${::tomcat::service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_suse.erb")
      }
    } else { # RHEL 7+ or Fedora
      file { "${::tomcat::service_name_real} service unit":
        path    => "/usr/lib/systemd/system/${::tomcat::service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_rhel.erb")
      }
    }

    service { $::tomcat::service_name_real:
      ensure   => $::tomcat::service_ensure,
      enable   => $::tomcat::service_enable,
      require  => File["${::tomcat::service_name_real} service unit"];
    }
    # temporary solution until a proper init script is included
  } else {
    $start_command = $::tomcat::jpda_enable ? {
      true    => "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${::tomcat::catalina_home_real}/bin/catalina.sh jpda start'",
      default => "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${::tomcat::catalina_home_real}/bin/catalina.sh start'"
    }
    $stop_command = "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${::tomcat::catalina_home_real}/bin/catalina.sh stop'"
    $status_command = "/usr/bin/pgrep -d , -u ${::tomcat::tomcat_user_real} -G ${::tomcat::tomcat_group_real} -f Dcatalina.base=${::tomcat::catalina_base_real}"

    service { $::tomcat::service_name_real:
      ensure   => $::tomcat::service_ensure,
      enable   => $::tomcat::service_enable,
      provider => base,
      start    => $start_command,
      stop     => $stop_command,
      status   => $status_command
    }
  }
}