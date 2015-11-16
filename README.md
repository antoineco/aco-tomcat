#tomcat
[![Build Status](https://travis-ci.org/antoineco/aco-tomcat.svg?branch=master)](https://travis-ci.org/antoineco/aco-tomcat)

####Table of Contents

1. [Overview - What is the tomcat module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with tomcat](#setup)
  * [Installation scenarios](#installation-scenarios)
  * [Configuration scenarios](#configuration-scenarios)
4. [Usage - The classes and defined types available for configuration](#usage)
  * [Classes and Defined Types](#classes-and-defined-types)
    * [Class: tomcat](#class-tomcat)
    * [Define: tomcat::instance](#define-tomcatinstance)
    * [Common parameters](#common-parameters)
    * [Define: tomcat::userdb_entry](#define-tomcatuserdb_entry)
    * [Define: tomcat::context](#define-tomcatcontext)
5. [Testing - How to run the included spec tests](#testing)
6. [Contributors](#contributors)

##Overview

The tomcat module installs and configures Apache Tomcat instances from either the packages available in your distribution's repositories, or from any archive file you provide to it.

##Module description

This module will install the desired version of the Apache Tomcat Web Application Container from almost any possible source, including the repositories available on the target system (distribution repositories or third-party sources like [JPackage](http://www.jpackage.org) and [EPEL](https://fedoraproject.org/wiki/EPEL))  
A long list of parameters permit a fine-tuning of the server and the JVM. Tomcat's most common elements are provided, and virtually any missing parameters can be included using the hash parameters present in each block.  
It is also possible to configure, besides the server itself, admin applications, extra libraries, the log4j logger, etc.  
The creation of individual instances following [Apache's guidelines](http://tomcat.apache.org/tomcat-8.0-doc/RUNNING.txt) is supported via a custom type.

##Setup

tomcat will affect the following parts of your system:

* tomcat packages and dependencies
* tomcat service(s)
* instances configuration
* tomcat user database(s) and authorized users (defined type)

Including the main class is enough to install the default version of tomcat provided by your distribution, and run it with default settings.

```puppet
include tomcat
```

####Installation scenarios

Install from archive instead of distribution package

```puppet
class { 'tomcat':
  install_from => 'archive',
  version      => '8.0.15'
}
```

Disable main instance and setup 2 individual instances

```puppet
class { 'tomcat':
  service_ensure => 'stopped',
  service_enable => false
}
tomcat::instance { 'instance1':
  server_control_port => 8005,
  http_port           => 8080,
  ajp_connector       => false,
  …
}
tomcat::instance { 'instance2':
  server_control_port => 8006,
  http_port           => 8081,
  manage_firewall     => true,
  …
}
```

Start a second instance with a different tomcat version

```puppet
class { 'tomcat':
  install_from => 'archive',
  version      => '7.0.55'
  …
}
tomcat::instance { 'my_app':
  version => '8.0.18'
  …
}
```

Use a non-default JVM and run it with custom options

```puppet
class { 'tomcat':
  java_home => '/usr/java/jre1.7.0_65',
  java_opts => ['-server', '-Xmx2048m', '-Xms256m', '-XX:+UseConcMarkSweepGC']
}
```

Enable the manager/host-manager webapps and configure default admin

```puppet
class { 'tomcat':
  …
  admin_webapps        => true,
  create_default_admin => true,
  admin_user           => 'tomcatmaster',
  admin_password       => 'meow'
}
```

Add an additional admin for the manager

```puppet
tomcat::userdb_entry { 'foo':
  database => 'main UserDatabase',
  username => 'foo',
  password => 'bar',
  roles    => ['manager-gui', 'manager-script']
}
```

Use log4j for Tomcat internal logging and provide a custom XML configuration file

```puppet
class { 'tomcat':
  …
  log4j             => true,
  log4j_enable      => true,
  log4j_conf_type   => 'xml',
  log4j_conf_source => 'puppet:///modules/my_configs/tomcat_log4j.xml'
}
```

Use with custom packages/custom installation layouts (eg. with [Ulyaoth](https://forge.puppetlabs.com/aco/ulyaoth))

```puppet
class { 'tomcat':
  package_name               => 'ulyaoth-tomcat8',
  version                    => '8.0.15'
  service_name               => 'tomcat',
  config_path                => '/opt/tomcat/bin/setenv.sh',
  catalina_home              => '/opt/tomcat',
  catalina_pid               => '$CATALINA_TMPDIR/$SERVICE_NAME.pid',
  admin_webapps_package_name => 'ulyaoth-tomcat8-admin',
  tomcat_native              => true,
  tomcat_native_package_name => 'ulyaoth-tomcat-native'
  …
}
```

###Configuration scenarios

Enable the standard AJP connector on non-default port with custom parameters

```puppet
class { 'tomcat':
  …
  ajp_connector => true,
  ajp_port      => 8090,
  ajp_params    => { 'address' => '127.0.0.1', 'packetSize' => 12288 }
}
```

Configure custom connectors

```puppet
class { 'tomcat':
  …
  connectors => [
    { 'port'        => 9080,
      'protocol'    => 'org.apache.coyote.http11.Http11Nio2Protocol',
      'maxPostSize' => 2500000
    },
    { 'port' => 9081,
      'allowTrace' => true
    }
  ]
}
```

Configure custom listeners

```puppet
class { 'tomcat':
  …
  listeners => [
    { 'className' => 'org.apache.catalina.storeconfig.StoreConfigLifecycleListener'
    },
    { 'className'     => 'org.apache.catalina.startup.UserConfig',
      'directoryName' => 'public_html'
    }
}
```

Customize Host

```puppet
class { 'tomcat':
  …
  host_autodeploy      => false,
  host_deployOnStartup => false,
  host_unpackwars      => true,
  host_params          => { createDirs => true }
}
```

Enable the remote [JMX listener](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html#JMX_Remote_Lifecycle_Listener_-_org.apache.catalina.mbeans.JmxRemoteLifecycleListener) and remote JVM monitoring

```puppet
class { 'tomcat':
  …
  jmx_listener      => true,
  jmx_registry_port => '8050',
  jmx_server_port   => '8051',
  jmx_bind_address  => $ipaddress_eth0,
  catalina_opts     => [ '-Dcom.sun.management.jmxremote',
                         '-Dcom.sun.management.jmxremote.ssl=false',
                         '-Dcom.sun.management.jmxremote.authenticate=false' ]
}
```

Configure main context.xml

```puppet
class { 'tomcat':
  …
  context_params  => { 'docBase' => 'myapproot', 'useHttpOnly' => false },
  context_manager => { 'maxActiveSessions' => 1000 },
  context_resourcelinks => [
    { 'name'   => 'linkToGlobalResource',
      'global' => 'simpleValue',
      'type'   => 'java.lang.Integer'
    },
    { 'name'   => 'appDataSource',
      'global' => 'sharedDataSource',
      'type'   => 'javax.sql.DataSource'
    }
  ]
}
```

##Usage

This module distinguishes two different contexts:
* **global**: default instance and global libraries
* **instance**: individual tomcat instance

Both contexts share most of their parameters.

###Classes and Defined Types

####Class: `tomcat`

Primary class and entry point of the module

**Parameters within `tomcat`:**

**Packages and service**

#####`install_from`
What type of source to install from. The module will download the necessary files by itself. Valid values are `package` and `archive`. Defaults to `package`.

#####`package_name`
Tomcat package name. Ignored if installed from archive. Default depends on the distribution.

#####`tomcat_native`
Whether to install the Tomcat Native library. Boolean value. Defaults to `false`.

#####`tomcat_native_package_name`
Tomcat Native library package name. Default depends on the distribution. 

#####`log4j`
Whether to install the log4j library. Boolean value. Defaults to `false`.

#####`log4j_package_name`
Log4j package name. Default depends on the distribution.

See also [Common parameters](#common-parameters)

####Define: `tomcat::instance`

Create a tomcat instance

**Parameters within `tomcat::instance`:**

#####`root_path`
Absolute path to the root of all tomcat instances. Defaults to `/var/lib/tomcats`.  
*Note:* instances will be installed in `${root_path}/${title}` and $CATALINA_BASE will be set to that folder

#####`default_servlet`
Whether a [Default Servlet](https://tomcat.apache.org/tomcat-8.0-doc/default-servlet.html) (conf/web.xml) should be created for the instance.

See also [Common parameters](#common-parameters)

####Common parameters

Parameters common to both `tomcat` and `tomcat::instance`

**Packages and service**

#####`version`
Tomcat full version number. The valid format is 'x.y.z[-package_suffix]'  
Must include the full package suffix if tomcat is installed from a package repository, the package `ensure` attribute will be enforced to this value.  
*Note:* multi-version only supported if installed from archive

#####`archive_source`
Source of the tomcat server archive, if installed from archive. Supports local files, puppet://, http://, https:// and ftp://. Defaults to `http://archive.apache.org/dist/tomcat/tomcat-<maj_version>/v<version>/bin/apache-tomcat-<version>.tar.gz`

#####`checksum_verify`
Enable or disables the checksum verification of the tar.gz tomcat archive. Defaults to `false` (boolean).

#####`checksum_type`
Sets the checksum type to check agains (none|md5|sha1|sha2|sh256|sha384|sha512). Defaults to `none`.

#####`checksum`
The checksum to test against. Defaults to `undef` (string).

#####`service_name`
Tomcat service name. Defaults to `${package_name}` (global) / `${package_name}_${title}` (instance).

#####`service_ensure`
Whether the service should be running. Valid values are `stopped` and `running`. Defaults to `running`.

#####`service_enable`
Whether to enable the tomcat service. Boolean value. Defaults to `true`.

#####`systemd_service_type`
The value for the systemd service type if applicable.

#####`service_start`
Optional override command for starting the service. Default depends on the platform.

#####`service_stop`
Optional override command for stopping the service. Default depends on the platform.

#####`tomcat_user`
Tomcat user. Defaults to `${service_name}` (Debian) / `tomcat` (all other distributions).

#####`tomcat_group`
Tomcat group. Defaults to `${tomcat_user}`.

#####`enable_extras`
Whether to install tomcat extra libraries. Boolean value. Defaults to `false`.  
*Warning:* extra libraries are enabled globally if defined within the global context

#####`manage_firewall`
Whether to automatically manage firewall rules. Boolean value. Defaults to `false`.

**Security and administration**

#####`admin_webapps`
Whether to enable admin webapps (manager/host-manager). This will also install the required packages if tomcat was installed from package. This parameter is ignored if tomcat was installed from archive, since tomcat archives always contain these apps. Boolean value. Defaults to `true`.

#####`admin_webapps_package_name`
Admin webapps package name. Default depends on the distribution.

#####`create_default_admin`
Whether to create default admin user (roles: 'manager-gui', 'manager-script', 'admin-gui' and 'admin-script'). Boolean value. Defaults to `false`.

#####`admin_user`
Admin user name. Defaults to `tomcatadmin`.

#####`admin_password`
Admin user password. Defaults to `password`.

**Server configuration**

#####`server_control_port`
Server control port. Defaults to `8005` (global) / `8006` (instance). The Server can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `server_shutdown`: command string that must be received in order to shut down Tomcat. Defaults to `SHUTDOWN`.
 - `server_address`: address on which this server waits for a shutdown command
 - `server_params`: optional hash of additional attributes/values to put in the Server element

#####`apr_listener`
Whether to enable the [APR Lifecycle Listener](http://tomcat.apache.org/tomcat-8.0-doc/apr.html#APR_Lifecycle_Listener_Configuration). The Listener can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `apr_sslengine`: name of the SSLEngine to use with the APR Lifecycle Listener

#####`jmx_listener`
Whether to enable the [JMX Remote Lifecycle Listener](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html#JMX_Remote_Lifecycle_Listener_-_org.apache.catalina.mbeans.JmxRemoteLifecycleListener). The listener can be further configured via a series of parameters:
 - `jmx_registry_port`: JMX/RMI registry port for the JMX Remote Lifecycle Listener. Defaults to `8050` (global) / `8052` (instance).
 - `jmx_server_port`: JMX/RMI server port for the JMX Remote Lifecycle Listener. Defaults to `8051` (global) / `8053` (instance).
 - `jmx_bind_address`: JMX/RMI server interface address for the JMX Remote Lifecycle Listener. Defaults to `undef` (use tomcat default).

#####`listeners`
An array of custom `Listener` entries to be added to the `Server` block. Each entry is to be supplied as a hash of attributes/values for the `Listener` XML node. See [Listeners](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html) for the list of possible attributes.

#####`svc_name`
Name of the default [Service](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html). Defaults to `Catalina`. The Service can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `svc_params`: optional hash of additional attributes/values to put in the Service element

#####`threadpool_executor`
Whether to enable the default [Executor (thread pool)](http://tomcat.apache.org/tomcat-8.0-doc/config/executor.html). Boolean value. Defaults to `false`. The Executor can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `threadpool_name`: a unique reference name. Defaults to `tomcatThreadPool`.
 - `threadpool_nameprefix`: name prefix for each thread created by the executor
 - `threadpool_maxthreads`: max number of active threads in this pool
 - `threadpool_minsparethreads`: minimum number of threads always kept alive
 - `threadpool_params`: optional hash of additional attributes/values to put in the Executor

#####`executors`
An array of custom `Executor` entries to be added to the `Service` block. Each entry is to be supplied as a hash of attributes/values for the `Executor` XML node. See [Executor](http://tomcat.apache.org/tomcat-8.0-doc/config/executor.html) for the list of possible attributes.

#####`http_connector`
Whether to enable the [HTTP connector](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html). Boolean value. Defaults to `true`. The Connector can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `http_port`: HTTP connector port. Defaults to `8080` (global) / `8081` (instance).
 - `http_protocol`: protocol to use
 - `http_use_threadpool`: whether to use the previously described Executor within the HTTP connector. Boolean value. Defaults to `false`.
 - `http_connectiontimeout`: timeout for a connection
 - `http_uriencoding`: encoding to use for URI
 - `http_compression`: whether to use compression. Boolean value. Defaults to `false`.
 - `http_maxthreads`: maximum number of executor threads
 - `http_params`: optional hash of additional attributes/values to put in the HTTP connector
 
#####`ssl_connector`
Whether to enable the [SSL-enabled HTTP connector](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#SSL_Support). Boolean value. Defaults to `false`. The Connector can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `ssl_port`: SSL connector port. Defaults to `8443` (global) / `8444` (instance). The HTTP connector's `redirect port` will also be set to this value.
 - `ssl_protocol`: protocol to use
 - `ssl_use_threadpool`: whether to use the previously described Executor within the HTTPS connector (boolean)
 - `ssl_connectiontimeout`: timeout for a connection
 - `ssl_uriencoding`: encoding to use for URI
 - `ssl_compression`: whether to use compression. Boolean value. Defaults to `false`.
 - `ssl_maxthreads`: maximum number of executor threads
 - `ssl_clientauth`: whether to require a valid certificate chain from the client
 - `ssl_sslenabledprotocols`: SSL protocol(s) to use (explicitly by version)
 - `ssl_sslprotocol`: SSL protocol(s) to use (a single value may enable multiple protocols and versions)
 - `ssl_keystorefile`: path to keystore file
 - `ssl_params`: optional hash of additional attributes/values to put in the HTTPS connector

#####`ajp_connector`
Whether to enable the [AJP connector](http://tomcat.apache.org/tomcat-8.0-doc/config/ajp). Boolean value. Defaults to `true`. The Connector can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `ajp_port`: AJP connector port. Defaults to `8009` (global) / `8010` (instance).
 - `ajp_protocol`: protocol to use. Defaults to `AJP/1.3`
 - `ajp_use_threadpool`: whether to use the previously described Executor within the AJP connector.  Boolean value. Defaults to `false`.
 - `ajp_connectiontimeout`: timeout for a connection
 - `ajp_uriencoding`: encoding to use for URI
 - `ajp_maxthreads`: maximum number of executor threads
 - `ajp_params`: optional hash of additional attributes/values to put in the AJP connector

#####`connectors`
An array of custom `Connector` entries to be added to the `Service` block. Each entry is to be supplied as a hash of attributes/values for the `Connector` XML node. See [HTTP](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html)/[AJP](http://tomcat.apache.org/tomcat-8.0-doc/config/ajp.html) for the list of possible attributes.

#####`engine_name`
Name of the default [Engine](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html). Defaults to `Catalina`. The Engine can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `engine_defaulthost`: default host name. Defaults to `${host_name}`
 - `engine_jvmroute`: identifier which must be used in load balancing scenarios to enable session affinity
 - `engine_params`: optional hash of additional attributes/values to put in the Engine container

#####`lockout_realm`
Whether to enable the [LockOut Realm](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html#LockOut_Realm_-_org.apache.catalina.realm.LockOutRealm). Boolean value. Defaults to `true`.

#####`userdatabase_realm`
Whether to enable the [UserDatabase Realm](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html#UserDatabase_Realm_-_org.apache.catalina.realm.UserDatabaseRealm). 
Boolean value. Defaults to `true`. The User Database Realm is inserted within the Lock Out Realm if it is enabled.

#####`realms`
An array of custom `Realm` entries to be added to the `Engine` container. Each entry is to be supplied as a hash of attributes/values for the `Realm` XML node. See [Realm](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html) for the list of possible attributes.

#####`host_name`
Name of the default [Host](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html). Defaults to `localhost`. The Host can be further configured via a series of parameters (will use Tomcat's defaults if not specified):
 - `host_appbase`: Application Base directory for this virtual host
 - `host_autodeploy`: whether Tomcat should check periodically for new or updated web applications while Tomcat is running
 - `host_deployOnStartup`: whether web applications from this host should be automatically deployed when Tomcat starts
 - `host_undeployoldversions`: whether to clean unused versions of web applications deployed using parallel deployment
 - `host_unpackwars`: whether to unpack web application archive (WAR) files 
 - `host_params`: optional hash of additional attributes/values to put in the Host container

#####`singlesignon_valve`
Whether to enable the [Single Sign On Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Single_Sign_On_Valve). Boolean value. Defaults to `false`.

#####`accesslog_valve`
Whether to enable the [Access Log Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Log_Valve). Boolean value. Defaults to `true`.

#####`valves`
An array of custom `Valve` entries to be added to the `Host` container. Each entry is to be supplied as a hash of attributes/values for the `Valve` XML node. See [Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html) for the list of possible attributes.

#####`globalnaming_environments`
An array of `Environment` entries to be added to the `GlobalNamingResources` component. Each entry is to be supplied as a hash of attributes/values for the `Environment` XML node. See [Global Resources](http://tomcat.apache.org/tomcat-8.0-doc/config/globalresources.html#Environment_Entries) for the list of possible attributes.

#####`globalnaming_resources`
An array of `Resource` entries to be added to the `GlobalNamingResources` component. Each entry is to be supplied as a hash of attributes/values for the `Resource` XML node. See [Global Resources](http://tomcat.apache.org/tomcat-8.0-doc/config/globalresources.html) for the list of possible attributes.

**Context configuration**

#####`context_params`, `context_loader`, `context_manager`, `context_realm`, `context_resources`, `context_watchedresource`, `context_parameters`, `context_environments`, `context_listeners`, `context_valves`, `context_resourcedefs`, `context_resourcelinks`
See [tomcat::context](#define-tomcatcontext) defined type.

**Global configuration file / environment variables**

#####`config_path`
Absolute path to the environment configuration (*setenv*). Default depends on the platform.

Please see [catalina.sh](http://svn.apache.org/repos/asf/tomcat/tc8.0.x/trunk/bin/catalina.sh) for a description of the following environment variables.

#####`catalina_home`
$CATALINA_HOME. Default depends on the platform.

#####`catalina_base`
$CATALINA_BASE. Default depends on the platform.

#####`jasper_home`
$JASPER_HOME. Defaults to `catalina_home`.

#####`catalina_tmpdir`
$CATALINA_TMPDIR. Defaults to `${catalina_base}/temp`

#####`catalina_pid`
$CATALINA_PID. Defaults to: `/var/run/${service_name}.pid`

#####`catalina_opts`
$CATALINA_OPTS. Array. Defaults to `[]`.

#####`java_home`
$JAVA_HOME. Defaults to `undef` (use tomcat default).

#####`java_opts`
$JAVA_OPTS. Array. Defaults to `['-server']`.

#####`jpda_enable`
Enable JPDA debugger. Boolean value. Effective only if installed from archive. Defaults to `false`.

#####`jpda_transport`
$JPDA_TRANSPORT. Defaults to `undef` (use tomcat default).

#####`jpda_address`
$JPDA_ADDRESS. Defaults to `undef` (use tomcat default).

#####`jpda_suspend`
$JPDA_SUSPEND. Defaults to `undef` (use tomcat default).

#####`jpda_opts`
$JPDA_OPTS. Array. Defaults to `[]`.

#####`security_manager`
Whether to enable the security manager. Boolean value. Defaults to `false`.

#####`lang`
Tomcat locale. Defaults to `undef` (use tomcat default).

#####`shutdown_wait`
How long to wait for a graceful shutdown before killing the process. Value in seconds. Only available on RedHat 6 systems if installed from package. Defaults to `30`.

#####`shutdown_verbose`
Whether to display start/shutdown messages. Boolean value. Only available on RedHat 6 systems if installed from package. Defaults to `false`.

#####`custom_variables`
Hash of custom environment variables.

**Logging**

Some extra documentation about [log4j](http://logging.apache.org/log4j/)'s usage with tomcat is available on [this page](http://tomcat.apache.org/tomcat-8.0-doc/logging.html#Using_Log4j).

#####`log_path`
Absolute path to the log directory. Defaults to `/var/log/$service_name`.

#####`log4j_enable`
Whether to use log4j rather than *java.util.logging* for Tomcat internal logging. Boolean value. Defaults to `false`.  
*Warning:* log4j is enabled globally if defined within the global context

#####`log4j_conf_type`
Log4j configuration type. Valid values are `ini` and `xml`. Defaults to `ini`.

#####`log4j_conf_source`
Where to get log4j's configuration from. A [sample file](https://raw.githubusercontent.com/tOnI0/aco-tomcat/master/files/log4j/log4j.properties) is provided with this module. Defaults to the sample file `log4j.properties`.

####Define: `tomcat::userdb_entry`

Create tomcat UserDatabase entries

**Parameters within `tomcat::userdb_entry`:**

#####`database`
Which database file the entry should be added to. `main UserDatabase` (global) / `instance ${name} UserDatabase` (instance)

#####`username`
User name (string)

#####`password`
User password (string)

#####`roles`
User roles (array)

####Define: `tomcat::context`

Create tomcat context files

**Parameters within `tomcat::context`:**

#####`path`
Absolute path indicating where the context file should be created. Mandatory. Does not create parent folders.

#####`params`
A hash of attributes/values for the `Context` container. See [Context](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Attributes) for the list of possible attributes.

#####`loader`
A hash of attributes/values for the `Loader` nested component. See [Loader](http://tomcat.apache.org/tomcat-8.0-doc/config/loader.html) for the list of possible attributes.

#####`manager`
A hash of attributes/values for the `Manager` nested component. See [Manager](http://tomcat.apache.org/tomcat-8.0-doc/config/manager.html) for the list of possible attributes.

#####`realm`
A hash of attributes/values for the `Realm` nested component. See [Realm](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html) for the list of possible attributes.

#####`resources`
A hash of attributes/values for the `Resources` nested component. See [Resources](http://tomcat.apache.org/tomcat-8.0-doc/config/resources.html) for the list of possible attributes.

#####`watchedresource`
An array of `WatchedResource` entries to be added to the `Context` container. Each entry is to be supplied as a string. Defaults to `['WEB-INF/web.xml','${catalina.base}/conf/web.xml']`

#####`parameters`
An array of `Parameter` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Parameter` XML node. See [Context Parameters](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Context_Parameters) for the list of possible attributes.

#####`environments`
An array of `Environment` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Environment` XML node. See [Environment Entries](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Environment_Entries) for the list of possible attributes.

#####`listeners`
An array of `Listener` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Listener` XML node. See [Lifecycle Listeners](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Lifecycle_Listeners) for the list of possible attributes.

#####`valves`
An array of `Valve` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Valve` XML node. See [Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html) for the list of possible attributes.

#####`resourcedefs`
An array of `Resource` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Resource` XML node. See [Resource Definitions](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Resource_Definitions) for the list of possible attributes.

#####`resourcelinks`
An array of `ResourceLink` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `ResourceLink` XML node. See [Resource Links](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Resource_Links) for the list of possible attributes.

##Testing

The only prerequisite is to have the [Bundler](http://bundler.io/) gem installed:

```shell
$ gem install bundler
```

Install gem dependencies using Bundler (related documentation page [here](http://bundler.io/bundle_install.html)):

```shell
$ bundle install
```

When your environment is set up, run the spec tests inside the module directory using:

```shell
$ bundle exec rake spec
```

Check the [puppetlabs_spec_helper](https://github.com/puppetlabs/puppetlabs_spec_helper) GitHub repository for more information.

##Contributors

* [ETL](https://github.com/etlweather)
* [Jason Hane](https://github.com/hanej)
* [Josh Baird](https://github.com/joshuabaird)
* [Frank Holtz](https://github.com/scitechfh)

Features request and contributions are always welcome!
