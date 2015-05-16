# == Class: tomcat::service::archive
#
# This class configures the tomcat service when installed from archive
#
class tomcat::service::archive {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # forward variables used in templates
  $service_start_real = $::tomcat::service_start_real
  $service_stop_real = $::tomcat::service_stop_real
  $service_name_real = $::tomcat::service_name_real
  $config_path_real = $::tomcat::config_path_real

  if $::tomcat::params::systemd {
    # manage systemd unit on compatible systems
    if $::osfamily == 'Suse' { # SuSE
      file { "${::tomcat::service_name_real} service unit":
        ensure  => 'file',
        path    => "/usr/lib/systemd/system/${::tomcat::service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_suse.erb")
      }
    } elsif $::operatingsystem == 'Fedora' and $::operatingsystemmajrelease >= '20' { # Fedora 20+
      file { "${::tomcat::service_name_real} service unit":
        ensure  => 'file',
        path    => "/usr/lib/systemd/system/${::tomcat::service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_fedora.erb")
      }
    } else { # RHEL 7+ or Fedora 17-19
      file { "${::tomcat::service_name_real} service unit":
        ensure  => 'file',
        path    => "/usr/lib/systemd/system/${::tomcat::service_name_real}.service",
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/instance/systemd_unit_rhel.erb")
      }
    }
  } else { # Debian/Ubuntu, RHEL 6, SLES 11, ...
    $start_command = "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${::tomcat::service_start_real}'"
    $stop_command = "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${::tomcat::service_stop_real}'"
    $status_command = "/usr/bin/pgrep -d , -u ${::tomcat::tomcat_user_real} -G ${::tomcat::tomcat_group_real} -f Dcatalina.base=${::tomcat::catalina_base_real}"

    # create init script
    file { "${::tomcat::service_name_real} service unit":
      ensure  => 'file',
      path    => "/etc/init.d/${::tomcat::service_name_real}",
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("${module_name}/instance/tomcat_init_generic.erb")
    }
  }

  service { $::tomcat::service_name_real:
    ensure  => $::tomcat::service_ensure,
    enable  => $::tomcat::service_enable,
    require => File["${::tomcat::service_name_real} service unit"];
  }
}
