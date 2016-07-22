# == Class: tomcat::extras
#
class tomcat::extras {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  Archive {
    provider => 'curl',
    extract  => false,
    require  => File['global extras directory'],
    cleanup  => false,
    notify   => Service[$::tomcat::service_name_real]
  }

  archive {
    'catalina-jmx-remote.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/catalina-jmx-remote-${::tomcat::version_real}.jar",
      source => "${::tomcat::extras_source_real}/catalina-jmx-remote.jar"
    ;

    'catalina-ws.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/catalina-ws-${::tomcat::version_real}.jar",
      source => "${::tomcat::extras_source_real}/catalina-ws.jar"
    ;

    'tomcat-juli-adapters.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-adapters-${::tomcat::version_real}.jar",
      source => "${::tomcat::extras_source_real}/tomcat-juli-adapters.jar"
    ;

    'tomcat-juli-extras.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-extras-${::tomcat::version_real}.jar",
      source => "${::tomcat::extras_source_real}/tomcat-juli.jar"
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
      target => "extras/catalina-jmx-remote-${::tomcat::version_real}.jar";

    'catalina-ws.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/catalina-ws.jar",
      target => "extras/catalina-ws-${::tomcat::version_real}.jar";

    'tomcat-juli-adapters.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/tomcat-juli-adapters.jar",
      target => "extras/tomcat-juli-adapters-${::tomcat::version_real}.jar";

    'tomcat-juli-extras.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/tomcat-juli-extras.jar",
      target => "extras/tomcat-juli-extras-${::tomcat::version_real}.jar"
  }
}
