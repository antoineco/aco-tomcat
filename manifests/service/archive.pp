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
  $tomcat_user = $::tomcat::tomcat_user_real
  $tomcat_group = $::tomcat::tomcat_group_real
  $systemd_service_type_real = $::tomcat::systemd_service_type_real

  $notify_service = $::tomcat::restart_on_change ? {
    true  => Service[$::tomcat::service_name_real],
    false => undef,
  }

  if $::tomcat::params::systemd {
    # manage systemd unit on compatible systems
    if $::osfamily == 'Suse' {
      $systemd_template = "${module_name}/instance/systemd_unit_suse.erb"
    } else { # Fedora, RHEL 7+
      $systemd_template = "${module_name}/instance/systemd_unit_rhel.erb"
    }
    # write service file
    file { "${service_name_real} service unit":
      path    => "/usr/lib/systemd/system/${service_name_real}.service",
      owner   => 'root',
      group   => 'root',
      content => template($systemd_template)
    }
    # Refresh systemd configuration
    exec { "refresh_${service_name_real}":
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
      subscribe   => File["${service_name_real} service unit"],
      notify      => $notify_service
    }
  } else { # Debian/Ubuntu, RHEL 6, SLES 11, ...
    $start_command = "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${tomcat_user} -s /bin/bash -c '${service_start_real}'"
    $stop_command = "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${tomcat_user} -s /bin/bash -c '${service_stop_real}'"
    $status_command = "/usr/bin/pgrep -d , -u ${tomcat_user} -G ${tomcat_group} -f Dcatalina.base=${::tomcat::catalina_base_real}"

    # create init script
    file { "${service_name_real} service unit":
      ensure  => present,
      path    => "/etc/init.d/${service_name_real}",
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("${module_name}/instance/tomcat_init_generic.erb"),
      notify  => $notify_service
    }
  }

  service { $service_name_real:
    ensure  => $::tomcat::service_ensure,
    enable  => $::tomcat::service_enable,
    require => File["${service_name_real} service unit"];
  }
}
