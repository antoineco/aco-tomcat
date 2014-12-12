# == Class: tomcat::extras
#
class tomcat::extras {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  Archive {
    cleanup => false,
    require => File['extras directory']
  }

  archive {
    'catalina-jmx-remote.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/catalina-jmx-remote-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-jmx-remote.jar"
    ;

    'catalina-ws.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/catalina-ws-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/catalina-ws.jar"
    ;

    'tomcat-juli-adapters.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-adapters-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli-adapters.jar"
    ;

    'tomcat-juli-extras.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/tomcat-juli-extras-${::tomcat::version}.jar",
      source => "http://archive.apache.org/dist/tomcat/tomcat-${::tomcat::maj_version}/v${::tomcat::version}/bin/extras/tomcat-juli.jar"
  }

  file {
    'extras directory':
      ensure  => directory,
      path    => "${::tomcat::catalina_home_real}/lib/extras",
      seltype => 'usr_t';

    'tomcat-juli.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/bin/tomcat-juli.jar",
      target => "${::tomcat::catalina_home_real}/lib/tomcat-juli-extras.jar",
      backup => true;

    'catalina-jmx-remote.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_home_real}/lib/catalina-jmx-remote.jar",
      target  => "extras/catalina-jmx-remote-${::tomcat::version}.jar",
      seltype => 'usr_t';

    'catalina-ws.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_home_real}/lib/catalina-ws.jar",
      target  => "extras/catalina-ws-${::tomcat::version}.jar",
      seltype => 'usr_t';

    'tomcat-juli-adapters.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_home_real}/lib/tomcat-juli-adapters.jar",
      target  => "extras/tomcat-juli-adapters-${::tomcat::version}.jar",
      seltype => 'usr_t';

    'tomcat-juli-extras.jar':
      ensure  => link,
      path    => "${::tomcat::catalina_home_real}/lib/tomcat-juli-extras.jar",
      target  => "extras/tomcat-juli-extras-${::tomcat::version}.jar",
      seltype => 'usr_t'
  }
}