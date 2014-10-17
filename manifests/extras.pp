# == Class: tomcat::extras
#
class tomcat::extras {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  if !defined(Package['wget']) {
    package { 'wget': ensure => present }
  }

  Exec {
    path    => '/usr/bin',
    cwd     => "${::tomcat::catalina_base_real}/lib/extras",
    timeout => 0,
    require => [Package['wget'], File['extras directory']]
  }

  exec {
    'get catalina-jmx-remote.jar':
      creates => "${::tomcat::catalina_base_real}/lib/extras/catalina-jmx-remote-${::tomcat::version}.jar",
      command => "wget http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-jmx-remote.jar\
       -O catalina-jmx-remote-${::tomcat::version}.jar";

    'get catalina-ws.jar':
      creates => "${::tomcat::catalina_base_real}/lib/catalina-ws-${::tomcat::version}.jar",
      command => "wget http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-ws.jar\
       -O catalina-ws-${::tomcat::version}.jar";

    'get tomcat-juli-adapters.jar':
      creates => "${::tomcat::catalina_base_real}/lib/tomcat-juli-adapters-${::tomcat::version}.jar",
      command => "wget http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli-adapters.jar\
       -O tomcat-juli-adapters-${::tomcat::version}.jar";

    'get tomcat-juli-extras.jar':
      creates => "${::tomcat::catalina_base_real}/lib/tomcat-juli-extras-${::tomcat::version}.jar",
      command => "wget http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli.jar\
       -O tomcat-juli-extras-${::tomcat::version}.jar";
  }

  file {
    'extras directory':
      ensure => directory,
      path => "${::tomcat::catalina_base_real}/lib/extras";

    'tomcat-juli.jar':
      ensure => link,
      path   => "${::tomcat::catalina_base_real}/bin/tomcat-juli.jar",
      target => "${::tomcat::catalina_base_real}/lib/tomcat-juli-extras.jar",
      backup => true;

    'catalina-jmx-remote.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_base_real}/lib/catalina-jmx-remote.jar",
      target  => "extras/catalina-jmx-remote-${::tomcat::version}.jar",
      seltype => 'usr_t';

    'catalina-ws.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_base_real}/lib/catalina-ws.jar",
      target  => "extras/catalina-ws-${::tomcat::version}.jar",
      seltype => 'usr_t';

    'tomcat-juli-adapters.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_base_real}/lib/tomcat-juli-adapters.jar",
      target  => "extras/tomcat-juli-adapters-${::tomcat::version}.jar",
      seltype => 'usr_t';

    'tomcat-juli-extras.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_base_real}/lib/tomcat-juli-extras.jar",
      target  => "extras/tomcat-juli-extras-${::tomcat::version}.jar",
      seltype => 'usr_t'
  }
}
