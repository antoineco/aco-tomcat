# == Class: tomcat::extras
#
class tomcat::extras {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  if $::tomcat::extra_source == undef {
    $extra_source="http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version_real}/bin/extras"
  } else {
    $extra_source=$::tomcat::extra_source
  }

  Archive {
    extract => false,
    require => File['global extras directory'],
    cleanup => false,
    notify  => Service[$::tomcat::service_name_real]
  }

  archive {
    "${::tomcat::catalina_home_real}/lib/extras/catalina-jmx-remote-${::tomcat::version_real}.jar":
      creates =>  "${::tomcat::catalina_home_real}/lib/extras/catalina-jmx-remote-${::tomcat::version_real}.jar",
      source  => "${extra_source}/catalina-jmx-remote.jar"
    ;

    "${::tomcat::catalina_home_real}/lib/extras/catalina-ws-${::tomcat::version_real}.jar":
      creates => "${::tomcat::catalina_home_real}/lib/extras/catalina-ws-${::tomcat::version_real}.jar",
      source  => "${extra_source}/catalina-ws.jar"
    ;

    "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-adapters-${::tomcat::version_real}.jar":
      creates => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-adapters-${::tomcat::version_real}.jar",
      source  => "${extra_source}/tomcat-juli-adapters.jar"
    ;

    "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-extras-${::tomcat::version_real}.jar":
      creates => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-extras-${::tomcat::version_real}.jar",
      source  => "${extra_source}/tomcat-juli.jar"
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
