#tomcat

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [To Do](#to-do)

##Overview

The tomcat module installs and configures an Apache Tomcat instance from any available YUM repository on [RHEL variants](http://en.wikipedia.org/wiki/List_of_Linux_distributions#RHEL-based), including Fedora.

##Module description

All RHEL-based Linux distributions provide one or more maintained packages of the Tomcat application server. These are available either from the distribution repositories or third-party sources ([JPackage](http://www.jpackage.org), [EPEL](https://fedoraproject.org/wiki/EPEL), ...). This module will install the desired version of tomcat and its dependencies from the repositories available on the target system.  
A long list of parameters permit a fine-tuning of the server and the JVM. It is for example possible to configure manager applications, install extra tomcat libraries, configure log4j as the standard logger, or enable the remote JMX listener.

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

Enable the AJP connector on default port

```puppet
class { '::tomcat':
  …
  ajp_connector => true,
  ajp_port      => 8009
}
```

Enable the manager/host-manager webapps and configure default admin

```puppet
class { '::tomcat':
  …
  manager        => true,
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

Use [log4j](http://tomcat.apache.org/tomcat-7.0-doc/logging.html#Using_Log4j) for Tomcat internal logging and provide a custom XML configuration file

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
  package_name   => 'ulyaoth-tomcat8',
  version        => '8.0.14'
  service_name   => 'tomcat',
  catalina_base  => '/opt/tomcat',
  enable_manager => false,   #usually included
  …
}
```

##Usage

####Class: `tomcat`

Primary class and entry point of the module

**Parameters within `tomcat`:**

#####`version`
Tomcat full version number. The valid format is 'x.y.z'. Default depends on the distribution.
#####`package_name`
Tomcat package name. Default depends on the distribution.
#####`service_name`
Tomcat service name. Defaults to the package name.
#####`service_ensure`
Whether the service should be running. Valid values are 'stopped' and 'running'.
#####`service_enable`
Enable service (boolean)
#####`tomcat_native`
Install Tomcat Native library (boolean)
#####`extras`
Install extra libraries (boolean)
#####`enable_manager`
Install admin webapps (boolean)
#####`create_default_admin`
Create default admin user (boolean)
#####`admin_user`
Admin user name
#####`admin_password`
Admin user password

(to be continued...)

####Define: `tomcat::userdb_entry`

Create tomcat UserDatabase entries

**Parameters within `tomcat::userdb_entry`:**

#####`username`
#####`password`
#####`roles`

(to be continued...)

##Limitations

This module has been written with my own experience in mind and might lack a feature or two you would like to have. I don't expect the possibilities it offers to cover every single use-case of Tomcat, since this would be close to impossible in a single Puppet module. In this case simply file a feature request on GitHub, I will be more than happy to improve this module based on the suggestions of the community.

##To Do

* Finish the documentation (procrastination issue)
* Allow the creation of several instances

Features request and contributions are always welcome!
