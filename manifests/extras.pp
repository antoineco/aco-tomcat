# == Class: tomcat::extras
#
class tomcat::extras {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  Archive {
    proxy_server => $::tomcat::proxy_server,
    proxy_type   => $::tomcat::proxy_type,
    extract      => false,
    cleanup      => false,
    require      => File['global extras directory'],
    notify       => $::tomcat::notify_service
  }

  archive {
    'catalina-jmx-remote.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/catalina-jmx-remote-${::tomcat::version_real}.jar",
      source => "${::tomcat::extras_source_real}/catalina-jmx-remote.jar"
    ;

    'catalina-ws.jar':
      path   => "${::tomcat::catalina_home_real}/lib/extras/catalina-ws-${::tomcat::version_real}.jar",
      source => "${::tomcat::extras_source_real}/catalina-ws.jar"
  }

  file {
    'global extras directory':
      ensure => directory,
      path   => "${::tomcat::catalina_home_real}/lib/extras";

    'catalina-jmx-remote.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/catalina-jmx-remote.jar",
      target => "extras/catalina-jmx-remote-${::tomcat::version_real}.jar";

    'catalina-ws.jar':
      ensure => link,
      path   => "${::tomcat::catalina_home_real}/lib/catalina-ws.jar",
      target => "extras/catalina-ws-${::tomcat::version_real}.jar";
  }
}
