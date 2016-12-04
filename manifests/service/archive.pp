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
  $catalina_base_real = $::tomcat::catalina_base_real
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
    # Template uses:
    # - $systemd_service_type_real
    # - $service_name_real
    # - $config_path_real
    # - $service_start_real
    # - $service_stop_real
    # - $tomcat_user
    # - $tomcat_group
    file { "${service_name_real} service unit":
      path    => "/etc/systemd/system/${service_name_real}.service",
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/instance/systemd_service_unit.erb")
    }
    # Refresh systemd configuration
    exec { "refresh ${service_name_real}":
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
      subscribe   => File["${service_name_real} service unit"],
      notify      => $notify_service
    }
  } else { # Debian, RHEL 6, SLES 11, ...
    $start_command = "/bin/su ${tomcat_user} -s /bin/bash -c '${service_start_real}'"
    $stop_command = "/bin/su ${tomcat_user} -s /bin/bash -c '${service_stop_real}'"
    $status_command = "/usr/bin/pgrep -d , -u ${tomcat_user} -G ${tomcat_group} -f Dcatalina.base=\$CATALINA_BASE"

    # create init script
    # Template uses:
    # - $catalina_base_real
    # - $start_command
    # - $stop_command
    # - $status_command
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
