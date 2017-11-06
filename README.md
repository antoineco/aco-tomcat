# tomcat
[![Build Status](https://travis-ci.org/antoineco/aco-tomcat.svg?branch=master)](https://travis-ci.org/antoineco/aco-tomcat)

#### Table of Contents

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
    * [Define: tomcat::userdb_role_entry](#define-tomcatuserdb_role_entry)
    * [Define: tomcat::context](#define-tomcatcontext)
    * [Define: tomcat::web](#define-tomcatweb)
5. [Testing - How to run the included spec tests](#testing)
6. [Contributors](#contributors)

## Overview

The tomcat module installs and configures Apache Tomcat instances from either the packages available in your distribution's repositories, or from any archive file you provide to it.

## Module description

This module will install the desired version of the Apache Tomcat Web Application Container from almost any possible source, including the repositories available on the target system (distribution repositories or third-party sources like [JPackage](http://www.jpackage.org) and [EPEL](https://fedoraproject.org/wiki/EPEL))  
A long list of parameters allow a fine tuning of the server and the JVM. Tomcat's most common elements are provided, and virtually any missing parameters can be included using the hash parameters present in each block.  
It is also possible to configure, besides the server itself, admin applications, extra libraries, etc.  
The creation of individual instances following [Apache's guidelines](http://tomcat.apache.org/tomcat-9.0-doc/RUNNING.txt) is supported via a custom type.

## Setup

tomcat will affect the following parts of your system:

* tomcat packages and dependencies
* tomcat service(s)
* instances configuration
* tomcat user database(s) and authorized users (defined type)

Including the main class is enough to install the default version of Tomcat provided by your distribution, and run it with default settings.

```puppet
include tomcat
```

#### Installation scenarios

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

Download Tomcat archives behind a proxy server

```puppet
class { 'tomcat':
  …
  proxy_server => 'http://user:password@proxy.example.com:8080'
}
```

### Configuration scenarios

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

Configure a nested HTTP/2 connector (Tomcat 8.5+)

```puppet
class { 'tomcat':
  …
  connectors => [
    { 'port'                     => 8443,
      'protocol'                 => 'org.apache.coyote.http11.Http11AprProtocol',
      'SSLEnabled'               => true,
      'defaultSSLHostConfigName' => 'example.com',
      'upgradeprotocol'          => {
        'className'   => 'org.apache.coyote.http2.Http2Protocol',
        'readTimeout' => 5000
      },
      'sslhostconfigs'           => [
        { 'hostName'         => 'example.com',
          'honorCipherOrder' => true,
          'certificates'     => [
            { 'certificateKeystoreFile' => 'conf/localhost.jks',
              'type'                    => 'RSA'
            },
            { 'certificateKeyFile'   => 'conf/localhost-key.pem',
              'certificateFile'      => 'conf/localhost-crt.pem',
              'certificateChainFile' => 'conf/localhost-chain.pem',
              'type'                 => 'RSA'
            }
          ]
        }
      ]
    }
  ]
}
```

Configure custom Listeners

```puppet
class { 'tomcat':
  …
  listeners => [
    { 'className' => 'org.apache.catalina.storeconfig.StoreConfigLifecycleListener'
    },
    { 'className'     => 'org.apache.catalina.startup.UserConfig',
      'directoryName' => 'public_html'
    }
  ]
}
```

Customize Host

```puppet
class { 'tomcat':
  …
  host_autodeploy      => false,
  host_deployonstartup => false,
  host_unpackwars      => true,
  host_params          => { createDirs => true },
  contexts             => [{ path => '', docBase => '/home/app', crossContext => true }]
}
```

Enable the remote [JMX listener](http://tomcat.apache.org/tomcat-9.0-doc/config/listeners.html#JMX_Remote_Lifecycle_Listener_-_org.apache.catalina.mbeans.JmxRemoteLifecycleListener) and remote JVM monitoring

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

Configure custom Realms

```puppet
class { 'tomcat':
  …
  realms => [
    { 'className' => 'org.apache.catalina.realm.MemoryRealm',
      'pathname'  => 'conf/myUsersDb.xml'
    },
    { 'className'         => 'org.apache.catalina.realm.DataSourceRealm',
      'dataSourceName'    => 'jdbc/myDataSource',
      'credentialhandler' => {
        'className' => 'org.apache.catalina.realm.MessageDigestCredentialHandler',
        'algorithm' => 'md5'
      }
    }
  ]
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

Configure default servlet (web.xml)

```puppet
class { 'tomcat':
  …
  default_servlet_listings => true,
  default_servlet_gzip     => true,
  default_servlet_params   => { 'sendfileSize' => 64 }
}
```

Configure security constraints (web.xml)

```puppet
class { 'tomcat':
  …
  security_constraints => [
    { 'display-name'            => 'Security constraint 1',
      'auth-constraint'         => { 'role-name' => ['admin', 'authenticated'] },
      'web-resource-collection' => { 'web-resource-name' => 'My sample web resource',
                                     'url-pattern'       => ['/example', '*.gif'],
                                     'http-method'       => ['GET', 'POST'] }
    },
    { 'display-name'            => 'Security constraint 2',
      'user-data-constraint'    => { 'transport-guarantee' => 'CONFIDENTIAL',
      'web-resource-collection' => { 'url-pattern'          => ['/protected/*'],
                                     'http-method-omission' => ['DELETE', 'PUT'] }
    }
  ]
}
```

Add an additional admin for the manager using a defined type

```puppet
tomcat::userdb_entry { 'foo':
  database => 'main UserDatabase',
  password => 'bar',
  roles    => ['manager-gui', 'manager-script']
}
```

Add roles and users using helper parameters

```puppet
class { 'tomcat':
  …
  tomcat_roles => {
    'opsgroup' => {} ,
    'qagroup'  => {}
  },
  tomcat_users => {
    'opsguy' => {
      password => 'qwerty',
      roles    => [ 'opsgroup', 'admin-gui' ]
    },
    'qaguy' => {
      password => '01234',
      roles    => [ 'qagroup', 'manager-gui' ]
    }
  }
}
```

## Usage

This module distinguishes two different contexts:
* **global**: default instance and global libraries
* **instance**: individual tomcat instance

Both contexts share most of their parameters.

### Classes and Defined Types

#### Class: `tomcat`

Primary class and entry point of the module

**Parameters within `tomcat`:**

**Packages and service**

##### `install_from`
What type of source to install from. The module will download the necessary files by itself. Valid values are `package` and `archive`. Defaults to `package`.

##### `package_name`
Tomcat package name. Ignored if installed from archive. Default depends on the distribution.

##### `package_ensure`
Tomcat package `ensure` attribute. Valid values are `undef`, `present` and `latest`. Defaults to `undef` (falls back to [`${version}`](#version)).

##### `tomcat_native`
Whether to install the Tomcat Native library. Boolean value. Defaults to `false`.

##### `tomcat_native_package_name`
Tomcat Native library package name. Default depends on the distribution.

##### `extras_package_name`
Package name for Tomcat extra libraries. If set, forces installation of Tomcat extra libraries from a package repository instead of Apache servers. The `ensure` attribute of the package resource will then default to the same value as [`${package_ensure}`](#package_ensure). Defaults to `undef`.

##### `admin_webapps_package_name`
Admin webapps package name. Default depends on the distribution.

See also [Common parameters](#common-parameters)

#### Define: `tomcat::instance`

Create a Tomcat instance

**Parameters within `tomcat::instance`:**

##### `root_path`
Absolute path to the root of all Tomcat instances. Defaults to `/var/lib/tomcats`.  
*Note:* instances will be installed in `${root_path}/${title}` and $CATALINA_BASE will be set to that directory

See also [Common parameters](#common-parameters)

#### Common parameters

Parameters common to both `tomcat` and `tomcat::instance`

**Packages and service**

##### `version`
Tomcat full version number. The valid format is 'x.y.z[.M##][-package_suffix]'. The package `ensure` attribute will be enforced to this value if Tomcat is installed from a package repository.  
Must include the full package suffix on Debian variants.  
*Note:* multi-version only supported if installed from archive

##### `archive_source`
Base path of the source of the Tomcat installation archive, if installed from archive. Supports local files, puppet://, http://, https:// and ftp://. Defaults to `http://archive.apache.org/dist/tomcat/tomcat-<maj_version>/v<version>/bin`.

##### `archive_filename`
File name of the Tomcat installation archive, if installed from archive. Defaults to `apache-tomcat-<version>.tar.gz`.

##### `proxy_server`
URL of a proxy server used for downloading Tomcat archives

##### `proxy_type`
Type of the proxy server. Valid values are `none`, `http`, `https` and `ftp`. Optional. Default determined by the scheme used in `${proxy_server}`

##### `checksum_verify`
Whether to enable the checksum verification of Tomcat installation archive. Boolean value. Defaults to `false`.

##### `checksum_type`
Checksum type. Valid values are `none`, `md5`, `sha1`, `sha2`, `sh256`, `sha384` and `sha512`. Defaults to `none`.

##### `checksum`
Checksum to test against. Defaults to `undef`.

##### `service_name`
Tomcat service name. Defaults to [`${package_name}`](#package_name) (global) / `${package_name}_${title}` (instance).

##### `service_ensure`
Whether the service should be running. Valid values are `stopped` and `running`. Defaults to `running`.

##### `service_enable`
Whether to enable the Tomcat service. Boolean value. Defaults to `true`.

##### `restart_on_change`
Whether to restart Tomcat service after configuration change. Boolean value. Defaults to `true`.

##### `systemd_service_type`
The value for the systemd service type if applicable. Defaults to 'simple' for install_from = package, 'forking' for install_from = archive.

##### `force_init`
Whether to force the generation of a generic init script/unit for the tomcat service. Useful for custom OS packages which do not include any. Defaults to `false`.

##### `service_start`
Optional override command for starting the service. Default depends on the platform.

##### `service_stop`
Optional override command for stopping the service. Default depends on the platform.

##### `tomcat_user`
Tomcat user. Defaults to [`${service_name}`](#service_name) (Debian) / `tomcat` (all other distributions).

##### `tomcat_group`
Tomcat group. Defaults to [`${tomcat_user}`](#tomcat_user).

##### `file_mode`
File mode for certain configuration xml files. Defaults to '0600'.

##### `extras_enable`
Whether to install Tomcat extra libraries. Boolean value. Defaults to `false`.  
*Warning:* extra libraries are enabled globally if defined within the global context

##### `extras_source`
Base path of the source of the Tomcat extra libraries. Supports local files, puppet://, http://, https:// and ftp://. Defaults to `http://archive.apache.org/dist/tomcat/tomcat-<maj_version>/v<version>/bin/extras`.

##### `manage_firewall`
Whether to automatically manage firewall rules. Boolean value. Defaults to `false`.

**Security and administration**

##### `admin_webapps`
Whether to enable admin webapps (manager/host-manager). This will also install the required packages if Tomcat was installed from package. This parameter is ignored if Tomcat was installed from archive, since Tomcat archives always contain these apps. Boolean value. Defaults to `true`.

##### `create_default_admin`
Whether to create default admin user (roles: 'manager-gui', 'manager-script', 'admin-gui' and 'admin-script'). Boolean value. Defaults to `false`.

##### `admin_user`
Admin user name. Defaults to `tomcatadmin`.

##### `admin_password`
Admin user password. Defaults to `password`.

##### `tomcat_users`
Optional hash containing UserDatabase user entries. See [tomcat::userdb_entry](#define-tomcatuserdb_entry). Defaults to an empty hash.

##### `tomcat_roles`
Optional hash containing UserDatabase role entries. See [tomcat::userdb_role_entry](#define-tomcatuserdb_role_entry). Defaults to an empty hash.

**Server configuration**

##### `server_control_port`
Server control port. Defaults to `8005` (global) / `8006` (instance). The [Server](https://tomcat.apache.org/tomcat-9.0-doc/config/server.html) can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `server_shutdown`: command string that must be received in order to shut down Tomcat. Defaults to `SHUTDOWN`.
 - `server_address`: address on which this server waits for a shutdown command
 - `server_params`: optional hash of additional attributes/values to put in the Server element

##### `jrememleak_attrs`
Optional hash of attributes for the [JRE Memory Leak Prevention Listener](http://tomcat.apache.org/tomcat-9.0-doc/config/listeners.html#JRE_Memory_Leak_Prevention_Listener_-_org.apache.catalina.core.JreMemoryLeakPreventionListener). Defaults to an empty hash.

##### `versionlogger_listener`
Whether to enable the [Version Logging Lifecycle Listener](https://tomcat.apache.org/tomcat-9.0-doc/config/listeners.html#Version_Logging_Lifecycle_Listener_-_org.apache.catalina.startup.VersionLoggerListener). The Listener can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `versionlogger_logargs`: log command line arguments
 - `versionlogger_logenv`: log current environment variables
 - `versionlogger_logprops`: log current Java system properties

##### `apr_listener`
Whether to enable the [APR Lifecycle Listener](http://tomcat.apache.org/tomcat-9.0-doc/apr.html#APR_Lifecycle_Listener_Configuration). The Listener can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `apr_sslengine`: name of the SSLEngine to use with the APR Lifecycle Listener

##### `jmx_listener`
Whether to enable the [JMX Remote Lifecycle Listener](http://tomcat.apache.org/tomcat-9.0-doc/config/listeners.html#JMX_Remote_Lifecycle_Listener_-_org.apache.catalina.mbeans.JmxRemoteLifecycleListener). The listener can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `jmx_registry_port`: JMX/RMI registry port for the JMX Remote Lifecycle Listener. Defaults to `8050` (global) / `8052` (instance).
 - `jmx_server_port`: JMX/RMI server port for the JMX Remote Lifecycle Listener. Defaults to `8051` (global) / `8053` (instance).
 - `jmx_bind_address`: JMX/RMI server interface address for the JMX Remote Lifecycle Listener
 - `jmx_uselocalports`: force usage of local ports to connect to the the JMX/RMI server

##### `listeners`
An array of custom `Listener` entries to be added to the `Server` block. Each entry is to be supplied as a hash of attributes/values for the `Listener` XML node. See [Listeners](http://tomcat.apache.org/tomcat-9.0-doc/config/listeners.html) for the list of possible attributes.

##### `svc_name`
Name of the default [Service](http://tomcat.apache.org/tomcat-9.0-doc/config/service.html). Defaults to `Catalina`. The Service can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `svc_params`: optional hash of additional attributes/values to put in the Service element

##### `threadpool_executor`
Whether to enable the default [Executor (thread pool)](http://tomcat.apache.org/tomcat-9.0-doc/config/executor.html). Boolean value. Defaults to `false`. The Executor can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `threadpool_name`: a unique reference name. Defaults to `tomcatThreadPool`.
 - `threadpool_nameprefix`: name prefix for each thread created by the executor
 - `threadpool_maxthreads`: max number of active threads in this pool
 - `threadpool_minsparethreads`: minimum number of threads always kept alive
 - `threadpool_params`: optional hash of additional attributes/values to put in the Executor

##### `executors`
An array of custom `Executor` entries to be added to the `Service` block. Each entry is to be supplied as a hash of attributes/values for the `Executor` XML node. See [Executor](http://tomcat.apache.org/tomcat-9.0-doc/config/executor.html) for the list of possible attributes.

##### `http_connector`
Whether to enable the [HTTP connector](http://tomcat.apache.org/tomcat-9.0-doc/config/http.html). Boolean value. Defaults to `true`. The Connector can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `http_port`: HTTP connector port. Defaults to `8080` (global) / `8081` (instance).
 - `http_protocol`: protocol to use
 - `http_use_threadpool`: whether to use the default Executor within the HTTP connector. Defaults to `false`.
 - `http_connectiontimeout`: timeout for a connection
 - `http_uriencoding`: encoding to use for URI
 - `http_compression`: whether to use compression. Defaults to `false`.
 - `http_maxthreads`: maximum number of executor threads
 - `http_params`: optional hash of additional attributes/values to put in the HTTP connector

##### `ssl_connector`
Whether to enable the [SSL-enabled HTTP connector](http://tomcat.apache.org/tomcat-9.0-doc/config/http.html#SSL_Support). Boolean value. Defaults to `false`. The Connector can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `ssl_port`: SSL connector port. Defaults to `8443` (global) / `8444` (instance). The HTTP connector's `redirect port` will also be set to this value.
 - `ssl_protocol`: protocol to use
 - `ssl_use_threadpool`: whether to use the default Executor within the HTTPS connector
 - `ssl_connectiontimeout`: timeout for a connection
 - `ssl_uriencoding`: encoding to use for URI
 - `ssl_compression`: whether to use compression. Defaults to `false`.
 - `ssl_maxthreads`: maximum number of executor threads
 - `ssl_clientauth`: whether to require a valid certificate chain from the client
 - `ssl_sslenabledprotocols`: SSL protocol(s) to use (explicitly by version)
 - `ssl_sslprotocol`: SSL protocol(s) to use (a single value may enable multiple protocols and versions)
 - `ssl_keystorefile`: path to keystore file
 - `ssl_params`: optional hash of additional attributes/values to put in the HTTPS connector

##### `ajp_connector`
Whether to enable the [AJP connector](http://tomcat.apache.org/tomcat-9.0-doc/config/ajp). Boolean value. Defaults to `true`. The Connector can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `ajp_port`: AJP connector port. Defaults to `8009` (global) / `8010` (instance).
 - `ajp_protocol`: protocol to use. Defaults to `AJP/1.3`.
 - `ajp_use_threadpool`: whether to use the default Executor within the AJP connector. Defaults to `false`.
 - `ajp_connectiontimeout`: timeout for a connection
 - `ajp_uriencoding`: encoding to use for URI
 - `ajp_maxthreads`: maximum number of executor threads
 - `ajp_params`: optional hash of additional attributes/values to put in the AJP connector

##### `connectors`
An array of custom `Connector` entries to be added to the `Service` block. Each entry is to be supplied as a hash of attributes/values for the `Connector` XML node. See [HTTP](http://tomcat.apache.org/tomcat-9.0-doc/config/http.html)/[AJP](http://tomcat.apache.org/tomcat-9.0-doc/config/ajp.html) for the list of possible attributes.  
Additionally, the following attributes are treated differently and used to configure nested elements:
 - `upgradeprotocol`: [HTTP Upgrade Protocol element](https://tomcat.apache.org/tomcat-9.0-doc/config/http2.html). Hash parameter
 - `sslhostconfigs`: [SSLHostConfig element(s)](https://tomcat.apache.org/tomcat-9.0-doc/config/http.html#SSL_Support_-_SSLHostConfig). Array of Hashs parameter
   - `certificates`: [Certificate element(s)](https://tomcat.apache.org/tomcat-9.0-doc/config/http.html#SSL_Support_-_Certificate). Array of Hashs parameter

##### `engine_name`
Name of the default [Engine](http://tomcat.apache.org/tomcat-9.0-doc/config/engine.html). Defaults to `Catalina`. The Engine can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `engine_defaulthost`: default host name. Defaults to [`${host_name}`](#host_name).
 - `engine_jvmroute`: identifier which must be used in load balancing scenarios to enable session affinity
 - `engine_params`: optional hash of additional attributes/values to put in the Engine container

##### `combined_realm`
Whether to enable the [Combined Realm](http://tomcat.apache.org/tomcat-9.0-doc/config/realm.html#Combined_Realm_-_org.apache.catalina.realm.CombinedRealm). Boolean value. Defaults to `false`.

##### `lockout_realm`
Whether to enable the [LockOut Realm](http://tomcat.apache.org/tomcat-9.0-doc/config/realm.html#LockOut_Realm_-_org.apache.catalina.realm.LockOutRealm). Boolean value. Defaults to `true`.

##### `userdatabase_realm`
Whether to enable the [UserDatabase Realm](http://tomcat.apache.org/tomcat-9.0-doc/config/realm.html#UserDatabase_Realm_-_org.apache.catalina.realm.UserDatabaseRealm).
Boolean value. Defaults to `true`. The User Database Realm is inserted within the Lock Out Realm if it is enabled.

##### `realms`
An array of custom `Realm` entries to be added to the `Engine` container. Each entry is to be supplied as a hash of attributes/values for the `Realm` XML node. See [Realm](http://tomcat.apache.org/tomcat-9.0-doc/config/realm.html) for the list of possible attributes.  
Additionally, the following attributes are treated differently and used to configure nested elements:
 - `credentialhandler`: [CredentialHandler Component](https://tomcat.apache.org/tomcat-9.0-doc/config/credentialhandler.html). Hash parameter

##### `host_name`
Name of the default [Host](http://tomcat.apache.org/tomcat-9.0-doc/config/host.html). Defaults to `localhost`. The Host can be further configured via a series of parameters (will use Tomcat's defaults when not specified):
 - `host_appbase`: Application Base directory for this virtual host
 - `host_autodeploy`: whether Tomcat should check periodically for new or updated web applications while Tomcat is running
 - `host_deployonstartup`: whether web applications from this host should be automatically deployed when Tomcat starts
 - `host_undeployoldversions`: whether to clean unused versions of web applications deployed using parallel deployment
 - `host_unpackwars`: whether to unpack web application archive (WAR) files
 - `host_params`: optional hash of additional attributes/values to put in the Host container

##### `contexts`
An array of custom `Context` entries to be added to the `Host` container. Each entry is to be supplied as a hash of attributes/values for the `Context` XML node. See [Context](http://tomcat.apache.org/tomcat-9.0-doc/config/context.html) for the list of possible attributes.

##### `singlesignon_valve`
Whether to enable the [Single Sign On Valve](http://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Single_Sign_On_Valve). Boolean value. Defaults to `false`.

##### `accesslog_valve`
Whether to enable the [Access Log Valve](http://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Access_Log_Valve). Boolean value. Defaults to `true`.

##### `accesslog_valve_pattern`
Pattern to use for the [Access Log Valve](http://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Access_Log_Valve).

##### `valves`
An array of custom `Valve` entries to be added to the `Host` container. Each entry is to be supplied as a hash of attributes/values for the `Valve` XML node. See [Valve](http://tomcat.apache.org/tomcat-9.0-doc/config/valve.html) for the list of possible attributes.

##### `engine_valves`
An array of custom `Valve` entries to be added to the `Engine` container. Each entry is to be supplied as a hash of attributes/values for the `Valve` XML node. See [Valve](http://tomcat.apache.org/tomcat-9.0-doc/config/valve.html) for the list of possible attributes.

##### `globalnaming_environments`
An array of `Environment` entries to be added to the `GlobalNamingResources` component. Each entry is to be supplied as a hash of attributes/values for the `Environment` XML node. See [Global Resources](http://tomcat.apache.org/tomcat-9.0-doc/config/globalresources.html#Environment_Entries) for the list of possible attributes.

##### `globalnaming_resources`
An array of `Resource` entries to be added to the `GlobalNamingResources` component. Each entry is to be supplied as a hash of attributes/values for the `Resource` XML node. See [Global Resources](http://tomcat.apache.org/tomcat-9.0-doc/config/globalresources.html#Resource_Definitions) for the list of possible attributes.

**Context configuration**

##### `context_params`, `context_loader`, `context_manager`, `context_realm`, `context_resources`, `context_watchedresource`, `context_parameters`, `context_environments`, `context_listeners`, `context_valves`, `context_resourcedefs`, `context_resourcelinks`
See [tomcat::context](#define-tomcatcontext) defined type.

**Servlets configuration**

##### `default_servlet_*`
initParameters for the `default` servlet. Generate a single hash for the [`${default_servlet_params}`](#default_servlet_params) parameter of the [tomcat::web](#define-tomcatweb) defined type (will use Tomcat's defaults when not specified)
 - `default_servlet_debug`: debugging level. Defaults to `0`.
 - `default_servlet_listings`: whether directory listing is shown if no welcome file is present. Defaults to `false`.
 - `default_servlet_gzip`: whether to serve gzipped files if the user agent supports gzip
 - `default_servlet_input`: input buffer size in bytes when reading resources to be served
 - `default_servlet_output`: output buffer size in bytes when writing resources to be served
 - `default_servlet_readonly`: whether to reject PUT and DELETE commands (http)
 - `default_servlet_fileencoding`: file encoding used for reading static resources
 - `default_servlet_showserverinfo`: whether to present server information in response sent to clients
 - `default_servlet_params`: optional hash of additional attributes/values to configure the `default` servlet

##### `jsp_servlet_*`
initParameters for the `jsp` servlet. Generate a single hash for the [`${jsp_servlet_params}`](#jsp_servlet_params) parameter of the [tomcat::web](#define-tomcatweb) defined type (will use Tomcat's defaults when not specified)
 - `jsp_servlet_checkinterval`: time in seconds between checks to see if a JSP page needs to be recompiled
 - `jsp_servlet_development`: whether to use Jasper in development mode
 - `jsp_servlet_enablepooling`: whether to enable tag handler pooling
 - `jsp_servlet_fork`: whether to perform JSP page compiles in a separate JVM from Tomcat. Defaults to `false`.
 - `jsp_servlet_genstringaschararray`: whether to generate text strings as char arrays
 - `jsp_servlet_javaencoding`: Java file encoding to use for generating java source files
 - `jsp_servlet_modificationtestinterval`: interval in seconds to check a JSP for modification
 - `jsp_servlet_trimspaces`: whether to trim white spaces in template text between actions or directives
 - `jsp_servlet_xpoweredby`: whether X-Powered-By response header is added by servlet. Defaults to `false`.
 - `jsp_servlet_params`: optional hash of additional attributes/values to configure the `jsp` servlet

##### `default_servletmapping_urlpatterns`, `jsp_servletmapping_urlpatterns`, `sessionconfig_sessiontimeout`, `sessionconfig_trackingmode`, `welcome_file_list`, `security_constraints`
See [tomcat::web](#define-tomcatweb) defined type.

**Global configuration file / environment variables**

##### `config_path`
Absolute path to the environment configuration (*setenv*). Default depends on the platform.

See [catalina.sh](http://svn.apache.org/repos/asf/tomcat/tc9.0.x/trunk/bin/catalina.sh) for a description of the following environment variables.

##### `catalina_home`
$CATALINA_HOME. Default depends on the platform.

##### `catalina_base`
$CATALINA_BASE. Default depends on the platform.

##### `jasper_home`
$JASPER_HOME. Defaults to `catalina_home`.

##### `catalina_tmpdir`
$CATALINA_TMPDIR. Defaults to `${catalina_base}/temp`.

##### `catalina_pid`
$CATALINA_PID. Defaults to: `/var/run/${service_name}.pid`.

##### `catalina_opts`
$CATALINA_OPTS. Array. Defaults to `[]`.

##### `java_home`
$JAVA_HOME. Defaults to `undef` (use Tomcat default).

##### `java_opts`
$JAVA_OPTS. Array. Defaults to `['-server']`.

##### `jpda_enable`
Enable JPDA debugger. Boolean value. Effective only if installed from archive. Defaults to `false`.

##### `jpda_transport`
$JPDA_TRANSPORT. Defaults to `undef` (use Tomcat default).

##### `jpda_address`
$JPDA_ADDRESS. Defaults to `undef` (use Tomcat default).

##### `jpda_suspend`
$JPDA_SUSPEND. Defaults to `undef` (use Tomcat default).

##### `jpda_opts`
$JPDA_OPTS. Array. Defaults to `[]`.

##### `security_manager`
Whether to enable the [Security Manager](https://tomcat.apache.org/tomcat-9.0-doc/security-manager-howto.html). Boolean value. Defaults to `false`.

##### `lang`
Tomcat locale. Defaults to `undef` (use Tomcat default).

##### `shutdown_wait`
How long to wait for a graceful shutdown before killing the process. Value in seconds. Only available on RedHat 6 systems if installed from package. Defaults to `30`.

##### `shutdown_verbose`
Whether to display start/shutdown messages. Boolean value. Only available on RedHat 6 systems if installed from package. Defaults to `false`.

##### `custom_variables`
Hash of custom environment variables.

**Logging**

##### `log_path`
Absolute path to the log directory. Defaults to `/var/log/${service_name}`.

##### `log_folder_mode`
Mode for log folder, in case of archive install. Defaults to '0660'.

#### Define: `tomcat::userdb_entry`

Create Tomcat UserDatabase user entries. For creating a `tomcat::userdb_entry` using Hiera, see parameter `tomcat_users`.

**Parameters within `tomcat::userdb_entry`:**

##### `database`
Which database file the entry should be added to. `main UserDatabase` (global) / `instance ${title} UserDatabase` (instance)

##### `username`
User name (string). Namevar.

##### `password`
User password (string)

##### `roles`
User roles (array)

#### Define: `tomcat::userdb_role_entry`

Create Tomcat UserDatabase role entries. For creating a `tomcat::userdb_role_entry` using Hiera, see parameter `tomcat_roles`.

**Parameters within `tomcat::userdb_role_entry`:**

##### `database`
Which database file the entry should be added to. `main UserDatabase` (global) / `instance ${title} UserDatabase` (instance)

##### `rolename`
Role name (string). Namevar.

#### Define: `tomcat::context`

Create Tomcat context files

**Parameters within `tomcat::context`:**

##### `path`
Absolute path indicating where the context file should be created. Mandatory. Does not create parent directories.

##### `owner`
File owner. Defaults to [`${tomcat_user}`](#tomcat_user).

##### `group`
File group. Defaults to [`${tomcat_group}`](#tomcat_group).

##### `file_mode`
File mode. Defaults to [`${file_mode}`](#file_mode).

##### `params`
A hash of attributes/values for the `Context` container. See [Context](http://tomcat.apache.org/tomcat-9.0-doc/config/context.html#Attributes) for the list of possible attributes.

##### `loader`
A hash of attributes/values for the `Loader` nested component. See [Loader](http://tomcat.apache.org/tomcat-9.0-doc/config/loader.html) for the list of possible attributes.

##### `manager`
A hash of attributes/values for the `Manager` nested component. See [Manager](http://tomcat.apache.org/tomcat-9.0-doc/config/manager.html) for the list of possible attributes.

##### `realm`
A hash of attributes/values for the `Realm` nested component. See [Realm](http://tomcat.apache.org/tomcat-9.0-doc/config/realm.html) for the list of possible attributes.  
Additionally, the following attributes are treated differently and used to configure nested elements:
 - `credentialhandler`: [CredentialHandler Component](https://tomcat.apache.org/tomcat-9.0-doc/config/credentialhandler.html). Hash parameter

##### `resources`
A hash of attributes/values for the `Resources` nested component. See [Resources](http://tomcat.apache.org/tomcat-9.0-doc/config/resources.html) for the list of possible attributes.

##### `watchedresource`
An array of `WatchedResource` entries to be added to the `Context` container. Each entry is to be supplied as a string. Defaults to `['WEB-INF/web.xml','${catalina.base}/conf/web.xml']`.

##### `parameters`
An array of `Parameter` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Parameter` XML node. See [Context Parameters](http://tomcat.apache.org/tomcat-9.0-doc/config/context.html#Context_Parameters) for the list of possible attributes.

##### `environments`
An array of `Environment` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Environment` XML node. See [Environment Entries](http://tomcat.apache.org/tomcat-9.0-doc/config/context.html#Environment_Entries) for the list of possible attributes.

##### `listeners`
An array of `Listener` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Listener` XML node. See [Lifecycle Listeners](http://tomcat.apache.org/tomcat-9.0-doc/config/context.html#Lifecycle_Listeners) for the list of possible attributes.

##### `valves`
An array of `Valve` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Valve` XML node. See [Valve](http://tomcat.apache.org/tomcat-9.0-doc/config/valve.html) for the list of possible attributes.

##### `resourcedefs`
An array of `Resource` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `Resource` XML node. See [Resource Definitions](http://tomcat.apache.org/tomcat-9.0-doc/config/context.html#Resource_Definitions) for the list of possible attributes.

##### `resourcelinks`
An array of `ResourceLink` entries to be added to the `Context` container. Each entry is to be supplied as a hash of attributes/values for the `ResourceLink` XML node. See [Resource Links](http://tomcat.apache.org/tomcat-9.0-doc/config/context.html#Resource_Links) for the list of possible attributes.

#### Define: `tomcat::web`

Create Tomcat web.xml files

**Parameters within `tomcat::web`:**

##### `path`
Absolute path indicating where the web.xml file should be created. Mandatory. Does not create parent directories.

##### `owner`
File owner. Defaults to [`${tomcat_user}`](#tomcat_user).

##### `group`
File group. Defaults to [`${tomcat_group}`](#tomcat_group).

##### `file_mode`
File mode. Defaults to [`${file_mode}`](#file_mode).

##### `default_servlet_params`
A hash of properties/values for the `default` servlet. See [Default Servlet](http://tomcat.apache.org/tomcat-9.0-doc/default-servlet.html) for the list of possible initParameters.

##### `jsp_servlet_params`
A hash of properties/values for the `jsp` servlet. See [Jasper 2 JSP Engine](https://tomcat.apache.org/tomcat-9.0-doc/jasper-howto.html) for the list of possible initParameters.

##### `default_servletmapping_urlpatterns`
List of request URI mapped to the `default` servlet. Defaults to `['/']`.

##### `jsp_servletmapping_urlpatterns`
List of request URI mapped to the `jsp` servlet. Defaults to `['*.jsp', '*.jspx']`.

##### `sessionconfig_sessiontimeout`
Default session timeout for applications, in minutes. Defaults to `30`. See [SessionConfig](https://tomcat.apache.org/tomcat-9.0-doc/api/org/apache/tomcat/util/descriptor/web/SessionConfig.html) for details about session configuration.

##### `sessionconfig_trackingmode`
Default session tracking mode for applications. See [Enum SessionTrackingMode](https://tomcat.apache.org/tomcat-9.0-doc/servletapi/javax/servlet/SessionTrackingMode.html) for a list of possible values, and [ServletContext.getEffectiveSessionTrackingModes()](https://tomcat.apache.org/tomcat-9.0-doc/servletapi/javax/servlet/ServletContext.html#getDefaultSessionTrackingModes--) for a description of the default behaviour.

##### `welcome_file_list`
List of file names to look up and serve when a request URI refers to a directory. Defaults to `['index.html', 'index.htm', 'index.jsp' ]`.

##### `security_constraints`
List of nested Hashs describing global [Security Constraints](https://javaee.github.io/tutorial/security-webtier002.html#specifying-security-constraints). The following keys accept an Array value:
 - `role-name` (child of `auth-constraint`)
 - `url-pattern` (child of `web-resource-collection`)
 - `http-method` (child of `web-resource-collection`)

## Testing

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

## Contributors

* [ETL](https://github.com/etlweather)
* [Jason Hane](https://github.com/hanej)
* [Josh Baird](https://github.com/joshuabaird)
* [Frank Holtz](https://github.com/scitechfh)
* [Vincent Kramar](https://github.com/thkrmr)
* [Joshua Roys](https://github.com/roysjosh)
* [Martin Zehetmayer](https://github.com/angrox)
* [Rurik Ylä-Onnenvuori](https://github.com/ruriky)
* [Hal Deadman](https://github.com/hdeadman)
* [Hervé Martin](https://github.com/HerveMARTIN)
* [Alessandro Franceschi](https://github.com/alvagante)

Features request and contributions are always welcome!
