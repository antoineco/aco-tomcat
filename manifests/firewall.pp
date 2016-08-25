# == Class: tomcat::firewall
#
class tomcat::firewall {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # http connector
  if $::tomcat::http_connector {
    firewall { "${::tomcat::http_port} accept - tomcat":
      dport  => $::tomcat::http_port,
      proto  => 'tcp',
      action => 'accept'
    }
  }

  # ajp connector
  if $::tomcat::ajp_connector {
    firewall { "${::tomcat::ajp_port} accept - tomcat":
      dport  => $::tomcat::ajp_port,
      proto  => 'tcp',
      action => 'accept'
    }
  }

  # ssl connector
  if $::tomcat::ssl_connector {
    firewall { "${::tomcat::ssl_port} accept - tomcat":
      dport  => $::tomcat::ssl_port,
      proto  => 'tcp',
      action => 'accept'
    }
  }

  # jmx
  if $::tomcat::jmx_listener {
    firewall { "${::tomcat::jmx_registry_port}/${::tomcat::jmx_server_port} accept - tomcat":
      dport  => [$::tomcat::jmx_registry_port, $::tomcat::jmx_server_port],
      proto  => 'tcp',
      action => 'accept'
    }
  }

  #cluster
  if $::tomcat::use_simpletcpcluster {
    firewall { "${::tomcat::cluster_receiver_port} accept - tomcat":
      dport  => $::tomcat::cluster_receiver_port,
      proto  => 'tcp',
      action => 'accept'
    }
    firewall { "${::tomcat::cluster_membership_port} accept - tomcat":
      sport       => $::tomcat::cluster_membership_port,
      dport       => $::tomcat::cluster_membership_port,
      proto       => 'udp',
      action      => 'accept',
      destination => '228.0.0.4'
    }
  }
}
