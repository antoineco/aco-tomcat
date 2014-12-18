# == Class: tomcat::extras
#
class tomcat::extras {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  Staging::File {
    require => File['global extras directory'],
    notify  => Service[$::tomcat::service_name_real]
  }

  staging::file {
    'catalina-jmx-remote.jar':
      target => "${::tomcat::catalina_home_real}/lib/extras/catalina-jmx-remote-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-jmx-remote.jar"
    ;

    'catalina-ws.jar':
      target => "${::tomcat::catalina_home_real}/lib/extras/catalina-ws-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-ws.jar"
    ;

    'tomcat-juli-adapters.jar':
      target => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-adapters-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli-adapters.jar"
    ;

    'tomcat-juli-extras.jar':
      target => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-extras-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli.jar"
  }

  file {
    'global extras directory':
      ensure => directory,
      path   => "${::tomcat::catalina_home_real}/lib/extras";

    'tomcat-juli.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/bin/tomcat-juli.jar",
      target => "${::tomcat::catalina_home_real}/lib/tomcat-juli-extras.jar",
      backup => true;

    'catalina-jmx-remote.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/catalina-jmx-remote.jar",
      target => "extras/catalina-jmx-remote-${::tomcat::version}.jar";

    'catalina-ws.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/catalina-ws.jar",
      target => "extras/catalina-ws-${::tomcat::version}.jar";

    'tomcat-juli-adapters.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/tomcat-juli-adapters.jar",
      target => "extras/tomcat-juli-adapters-${::tomcat::version}.jar";

    'tomcat-juli-extras.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/tomcat-juli-extras.jar",
      target => "extras/tomcat-juli-extras-${::tomcat::version}.jar"
  }
}