#tomcat

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [To Do](#to-do)

##Overview

The tomcat module installs and configures an Apache Tomcat instance from the available packages in your distribution's repositories.

##Module description

Almost all Linux distributions provide one or more maintained packages of the Tomcat application server. These are available either from the distribution repositories or third-party sources ([JPackage](http://www.jpackage.org), [EPEL](https://fedoraproject.org/wiki/EPEL), ...). This module will install the desired version of tomcat and its dependencies from the repositories available on the target system.  
A long list of parameters permit a fine-tuning of the server and the JVM. It is for example possible to configure admin applications, install extra tomcat libraries, configure log4j as the standard logger, or enable the remote JMX listener.

##Setup

tomcat will affect the following parts of your system:

* tomcat packages and dependencies
* tomcat service
* server and instance configuration
* tomcat user database and authorized users (defined type)

Including the main class is enough to install the default version of tomcat provided by your distribution, and run it with default settings.

```puppet
include ::tomcat
```

####A couple of examples

Use a non-default JVM and run it with custom options

```puppet
class { '::tomcat':
  java_home => '/usr/java/jre1.7.0_65',
  java_opts => '-server -Xmx2048m -Xms256m -XX:+UseConcMarkSweepGC'
}
```

Enable the AJP connector on non-default port

```puppet
class { '::tomcat':
  …
  ajp_connector => true,
  ajp_port      => 8090
}
```

Enable the manager/host-manager webapps and configure default admin

```puppet
class { '::tomcat':
  …
  admin_webapps  => true,
  admin_user     => 'tomcatmaster',
  admin_password => 'meow'
}
```

Add an additional admin for the manager

```puppet
::tomcat::userdb_entry { 'foo':
  username => 'foo',
  password => 'bar',
  roles    => ['manager-gui', 'manager-script']
}
```

Enable the remote [JMX listener](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html#JMX_Remote_Lifecycle_Listener_-_org.apache.catalina.mbeans.JmxRemoteLifecycleListener) for remote JVM monitoring

```puppet
class { '::tomcat':
  …
  jmx_listener      => true,
  jmx_registry_port => '8050',
  jmx_server_port   => '8051',
  catalina_opts     => '-Dcom.sun.management.jmxremote'
}
```

Use log4j for Tomcat internal logging and provide a custom XML configuration file

```puppet
class { '::tomcat':
  …
  log4j             => true,
  log4j_conf_type   => 'xml',
  log4j_conf_source => 'puppet:///modules/my_configs/tomcat_log4j.xml'
}
```
Use with custom packages/custom installation layouts (eg. with [Ulyaoth](https://forge.puppetlabs.com/aco/ulyaoth))

```puppet
class { '::tomcat':
  package_name               => 'ulyaoth-tomcat8',
  version                    => '8.0.14'
  service_name               => 'tomcat',
  catalina_home              => '/opt/tomcat',
  admin_webapps              => false,   #usually included
  tomcat_native              => true,
  tomcat_native_package_name => 'ulyaoth-tomcat-native'
  …
}
```

##Usage

####Class: `tomcat`

Primary class and entry point of the module

**Parameters within `tomcat`:**

**Packages and service**

#####`version`
Tomcat full version number. The valid format is 'x.y.z'. Default depends on the distribution.
*Note:* if you define it manually please make **sure** this version if available in your system's repositories, since many parameters depend on this version number
#####`package_name`
Tomcat package name. Default depends on the distribution.
#####`service_name`
Tomcat service name. Defaults to `package_name`.
#####`service_ensure`
Whether the service should be running. Valid values are `stopped` and `running`. Defaults to `running`.
#####`service_enable`
Whether to enable the tomcat service. Boolean value. Defaults to `true`.
#####`tomcat_native`
Whether to install the Tomcat Native library. Boolean value. Defaults to `false`.
#####`tomcat_native_package_name`
Tomcat Native library package name. Default depends on the distribution. 
#####`extras`
Whether to install tomcat extra libraries. Boolean value. Defaults to `false`.

**Security and administration**

#####`admin_webapps`
Whether to install admin webapps (manager/host-manager). Boolean value. Defaults to `true`.
#####`admin_webapps_package_name`
Admin webapps package name. Default depends on the distribution.
#####`create_default_admin`
Whether to create default admin user (roles: 'manager-gui', 'manager-script', 'admin-gui' and 'admin-script'). Boolean value. Defaults to `true`.
#####`admin_user`
Admin user name. Defaults to `tomcatadmin`.
#####`admin_password`
Admin user password. Defaults to `password`.

**Server configuration**

#####`control_port`
Server control port. Defaults to `8005`.
#####`threadpool_executor`
Whether to enable the [Executor (thread pool)](http://tomcat.apache.org/tomcat-8.0-doc/config/executor.html). Boolean value. Defaults to `false`.
#####`http_connector`
Whether to enable the [HTTP connector](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html). Boolean value. Defaults to `true`.
#####`http_port`
HTTP connector port. Defaults to `8080`.
#####`use_threadpool`
Whether to use the previously described Executor within the HTTP connector.	 Boolean value. Defaults to `false`.
#####`ssl_connector`
Whether to enable the [SSL-enabled HTTP connector](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#SSL_Support). Boolean value. Defaults to `false`.
#####`ssl_port`
SSL connector port. Defaults to `8443`.
#####`ajp_connector`
Whether to enable the [AJP connector](http://tomcat.apache.org/tomcat-8.0-doc/config/ajp). Boolean value. Defaults to `true`.
#####`ajp_port`
AJP connector port. Defaults to `8009`.
#####`jvmroute`
Engine's [jvmRoute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) attribute. Defaults to `undef`.
#####`hostname`
Name of the default [Host](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html). Defaults to `localhost`.
#####`autodeploy`, `deployOnStartup`, `undeployoldversions`, `unpackwars`
Host's [common attributes](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes). Use tomcat's defaults (see doc).
#####`singlesignon_valve`
Whether to enable the [Single Sign On Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Single_Sign_On_Valve). Boolean value. Defaults to `false`.
#####`accesslog_valve`
Whether to enable the [Access Log Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Log_Valve). Boolean value. Defaults to `true`.
#####`jmx_listener`
Whether to enable the [JMX Remote Lifecycle Listener](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html#JMX_Remote_Lifecycle_Listener_-_org.apache.catalina.mbeans.JmxRemoteLifecycleListener)
#####`jmx_registry_port`
JMX/RMI registry port. Defaults to `8050`.
#####`jmx_server_port`
JMX/RMI server port. Defaults to `8051`.
#####`jmx_bind_address`
JMX/RMI server interface address. Defaults to `undef`.

**Global configuration file / environment variables**

Please see [catalina.sh](http://svn.apache.org/repos/asf/tomcat/tc8.0.x/trunk/bin/catalina.sh) for a description of the following environment variables.
#####`catalina_home`
$CATALINA_HOME. Default depends on the platform.
#####`catalina_base`
$CATALINA_BASE. Default depends on the platform.
#####`jasper_home`
$JASPER_HOME. Defaults to `catalina_home`.
#####`catalina_tmpdir`
$CATALINA_TMPDIR. Defaults to `${catalina_home}/temp`
#####`catalina_pid`
$CATALINA_PID. Defaults to `/var/run/${service_name}.pid`
#####`java_home`
$JAVA_HOME. Defaults to `undef`.
#####`java_opts`
$JAVA_OPTS. Defaults to `-server`.
#####`catalina_opts`
$CATALINA_OPTS. Defaults to `undef`.
#####`security_manager`
Whether to enable the security manager. Boolean value. Defaults to `false`.
#####`tomcat_user`
Tomcat user. Defaults to `service_name`.
#####`tomcat_group`
Tomcat group. Defaults to `tomcat_user`.
#####`lang`
Tomcat locale. Defaults to `undef`.
#####`shutdown_wait`
How long to wait for a graceful shutdown before killing the process. Value in seconds. Defaults to `30`.

*Note:* RedHat only
#####`shutdown_verbose`
Whether to display start/shutdown messages. Boolean value. Defaults to `false`.

*Note:* RedHat only
#####`logfile_days`
Number of days to keep old log files. Defaults to `30`.
#####`logfile_compress`
Whether to compress logfiles older than today's. Boolean value. Defaults to `false`.
#####`custom_fragment`
Custom variables, one per line.

**Logging**

Some extra documentation about [log4j](http://logging.apache.org/log4j/)'s usage with tomcat is available on [this page](http://tomcat.apache.org/tomcat-8.0-doc/logging.html#Using_Log4j).
#####`log4j`
Whether to use log4j rather than java.util.logging for Tomcat internal logging. Boolean value. Defaults to `false`.
#####`log4j_package_name`
Log4j package name. Default depends on the distribution.
#####`log4j_conf_type`
Log4j configuration type. Valid values are `ini` and `xml`. Defaults to `ini`.
#####`log4j_conf_source`
Where to get log4j's configuration from. A [sample file](https://raw.githubusercontent.com/tOnI0/aco-tomcat/master/files/log4j.properties) is provided with this module. Defaults to the sample file `log4j.properties`.

####Define: `tomcat::userdb_entry`

Create tomcat UserDatabase entries

**Parameters within `tomcat::userdb_entry`:**

#####`username`
User name (string)
#####`password`
User password (string)
#####`roles`
User roles (array of strings)

##Limitations

* Only supports RedHat and Debian variants/derivatives (for now)

##To Do

* Allow the creation of several instances

Features request and contributions are always welcome!
