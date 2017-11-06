### 1.8.4

* Fix admin contexts resources ordering ([alvagante](https://github.com/alvagante))
* Update default package versions

### 1.8.3

* Add configuration of
  - nested Host contexts (`contexts` parameter) ([HerveMARTIN](https://github.com/HerveMARTIN))
  - global security constraints (`security_constraints` parameter)
* Update default package versions
* Add support for SuSE 12.3

### 1.8.2

* New parameters `log_folder_mode` and `accesslog_valve_pattern` ([HerveMARTIN](https://github.com/HerveMARTIN))
* Add support for Debian 9, OpenSuSE 42.3
* Drop support for Ubuntu 12.04, 12.10, 13.04, 13.10, Fedora 23, 24
* Update default package versions

### 1.8.1

Hotfix: remove references to tomcat-juli extra libraries

### 1.8.0

* Drop support for internal logging with log4j
  - [Removed](https://bz.apache.org/bugzilla/show_bug.cgi?id=58588) in Tomcat 8.5
* Update default package versions

### 1.7.0

* Add support for Tomcat 9
  - Configurable nested UpgradeProtocol, SSLHostConfig and Certificate elements (Connector)
  - Configurable nested CredentialHandler element (Realm)
  - *Refer to the configuration examples for further usage instructions*
* Make the VersionLogger Listener attributes configurable via `versionlogger_*` parameters
* Make the JreMemoryLeakPrevention Listener attributes configurable via `jrememleak_attrs` parameter
* New parameter `jmx_uselocalports` for the JMX Listener
* **Warning:** the path to Tomcat archives is now composed of both `archive_source` and `archive_filename` (new) parameters
* Fix ignored `listeners` parameter

### 1.6.2

* Add proxy support via new parameters `proxy_server` and `proxy_type`
* New parameter `force_init` which generates a generic init script/unit for packages which do not include any
* Add support for SuSE 12.1
* Update default package versions

### 1.6.1

* Unset `provider` parameter on all `archive` resources (from `puppet-archive` module)
  - quick and dirty workaround until [SERVER-94](https://tickets.puppetlabs.com/browse/SERVER-94) gets fixed
  - **Warning:** may break behind a HTTP proxy (untested)

### 1.6.0

* Configurable `web.xml` files
  - **Warning:** replaces `default_servlet` instance parameter
  - New `tomcat::web` defined type to manage `web.xml` files
  - See `default_servlet*`, `jsp_servlet*`, `sessionconfig_sessiontimeout` and `welcome_file_list` parameters
* Update systemd unit, expect tomcat script path as set in latest available packages
  - **Warning:** check the current location of your tomcat startup script, especially if using an old OS package version
* Replace or remove calls to deprecated `validate_*` stdlib functions
* Add support for Fedora 25 and Amazon Linux 2016.09
* Drop support for Fedora 22

### 1.5.0

**Warning:** the `host_deployOnStartup` parameter was renamed to `host_deployonstartup` (lowercase) in this release. Backward compatibility will be maintained until the next minor release only.

* New `tomcat::userdb_role_entry` defined type to manage roles in the user database ([hdeadman](https://github.com/hdeadman))
* New `tomcat_users` and `tomcat_roles` hash parameters to help the definition of users and roles ([hdeadman](https://github.com/hdeadman))
* Add support for Engine scoped valves: `engine_valves` parameter ([hdeadman](https://github.com/hdeadman))
* New parameters `restart_on_change` and `file_mode` ([ruriky](https://github.com/ruriky))
* Allow enabling the Security Manager on `archive` installations ([hdeadman](https://github.com/hdeadman))
* Fix default systemd service type on `archive` installations ([hdeadman](https://github.com/hdeadman))
* Improve usage of clustering features (SimpleTcpCluster) ([hdeadman](https://github.com/hdeadman))
  - see undocumented `cluster_*` parameters
* Fix empty user/group in systemd units
* Encode values in XML templates ([scitechfh](https://github.com/scitechfh))
* Set default provider to `curl` for `archive` resources ([scitechfh](https://github.com/scitechfh))
* Add support for Ubuntu 16.10 (Yakkety), OpenSuSE 42.2, SuSE 12.1
* Update default package versions

### 1.4.0

**Warning:** the `enable_extras` parameter was renamed to `extras_enable` in this release. Backward compatibility will be maintained until the next minor release only.

* New parameters: `package_ensure` and `extras_package_name` ([scitechfh](https://github.com/scitechfh))
* New parameters: `checksum_verify`, `checksum_type`, `checksum` and `extras_source` ([angrox](https://github.com/angrox))
* Replace dependency on `puppet/staging` by `puppet/archive`
* Align content of systemd templates on current state of official RPM packages (RedHat and derivatives)
* Add support for Ubuntu 16.04 (Xenial), Fedora 24 and Amazon Linux 2016.03
* Drop support for Debian 6 (Squeeze), OpenSuSE 13.1 and below, Fedora 21 and below
* Update default package versions
* Bug fixes:
  - parameters left blank in systemd units on some Puppet versions
  - work around for [PUP-1597](https://tickets.puppetlabs.com/browse/PUP-3615) on RHEL 7
  - dependency cycle between service and context resources
  - file permissions too strict on configuration files
  - activation of extras/log4j not working with multi-version setups
  - tomcat service not notified of all relevant changes

### 1.3.2

* New parameters: `globalnaming_environments` and `ssl_sslenabledprotocols` ([roysjosh](https://github.com/roysjosh))
* Support Amazon Linux 2015.x ([thkrmr](https://github.com/thkrmr))
* Update default package versions (Fedora 23)

### 1.3.1

* New `systemd_service_type` parameter ([joshuabaird](https://github.com/joshuabaird))
* Reload systemd daemon after unit update ([scitechfh](https://github.com/scitechfh))
* Update deprecated `port` firewall parameter ([scitechfh](https://github.com/scitechfh))
* Support Fedora 23

### 1.3.0

* Support per-instance user
* New `tomcat::instance` parameter: `default_servlet`
* Fix default owner/group on context.xml
* Contain sub-classes
* Update default package versions (Debian 6/7)
* Support Ubuntu 15.10

### 1.2.1

* Fix obsolete start/stop commands and systemd unit on RHEL7
* Support Epoch tag in package version
* Move information about tomcat user/group to the right place in the documentation
* Update default package versions (RHEL6/7)

### 1.2.0

Enforce tomcat package version. `version` now takes a full package version when tomcat is installed from a package repository.

### 1.1.0

New `tomcat::context` defined type to manage `context.xml` files

### 1.0.3

Fix regression due to changes in pid file management

### 1.0.2

* Add missing `ensure` attributes ([hanej](https://github.com/hanej))
* Do not force pid file creation (fixes startup issue with Tomcat 6)

### 1.0.1

Fix documentation format and add Context config example

### 1.0.0

* New Context parameters for configuring context.xml:
  - `context_params`
  - `context_loader`
  - `context_manager`
  - `context_realm`
  - `context_resources`
  - `context_parameters`
  - `context_environments`
  - `context_listeners`
  - `context_valves`
  - `context_resourcedefs`
  - `context_resourcelinks`
* Support Debian 8, Fedora 22 and RHEL 5
* Do not create user/group if already defined
* Minor bugfixes

### 0.9.3

* Allow several instances to use the same `log_path`
* Parameters validation
* Partial spec tests

### 0.9.2

* Enable multi-version tomcat installation
* New parameter `log_path`: define log directory
* Fix issue with generic init script always returning 0

### 0.9.1

Fix compatibility with future parser in Puppet 3.7.4 ([PUP-3615](https://tickets.puppetlabs.com/browse/PUP-3615))

### 0.9.0

**Warning:** this release is a big step forward, please read the documentation carefully

* New `listeners` parameters: create custom Listener components within the server configuration
* New Server parameters. Warning: `control_port` renamed to `server_control_port`
  - `server_control_port`
  - `server_shutdown`
  - `server_address`
* New Service parameters.
  - `svc_name`
  - `svc_params`
* New Engine parameters. Warning: `jvmroute` renamed to `engine_jvmroute`
  - `engine_name`
  - `engine_defaulthost`
  - `engine_jvmroute`
  - `engine_params`
* New Host parameters. Warning: **all** old parameters renamed and default values removed!
  - `host_name`
  - `host_appbase`
  - `host_autodeploy`
  - `host_deployOnStartup`
  - `host_undeployoldversions`
  - `host_unpackwars`
  - `host_params`
* Fix instance startup on Fedora 20+, drop support for Fedora 15 and 16
* `custom_fragment` renamed to `custom_variables` (hash)
* Refactoring

### 0.8.2

* New parameters related to Executors
  - `threadpool_name`
  - `threadpool_nameprefix`
  - `threadpool_maxthreads`
  - `threadpool_minsparethreads`
  - `threadpool_params`
  - `executors`

### 0.8.1

* Fix Critical messages generated when concaneting empty fragments to server.xml
* New parameter `valves`: create custom Valve components within the server configuration
* Change default value for `catalina_pid` (instance context) and manage pid file
* Improve template formatting

### 0.8.0

* Numerous new Connector parameters (see documentation, thanks [etlweather](https://github.com/etlweather) for the help)
* Split bulky server.xml template into independant fragments
* New `context_resources` parameter: add ResourceLink elements to context.xml ([etlweather](https://github.com/etlweather))
* Added basic support for SimpleTcpCluster ([etlweather](https://github.com/etlweather), experimental and undocumented, need contributions)
* Updated documentation

### 0.7.0

* New realm parameters: `$lockout_realm`, `$userdatabase_realm` ([etlweather](https://github.com/etlweather))
* New `globalnaming_resources` and `realms` parameters: possibility to define custom GlobalNamingResources and Realm elements ([etlweather](https://github.com/etlweather))
* Changed `root_path` default value (instance context)
* Proper startup script for distributions without systemd
* Better support of SuSE OS family
* Fix tomcat6 startup script on RHEL (warning: now requires stdlib >= 4.4.0)

### 0.6.0

* Compatible with future parser
* Minor code improvements

### 0.5.4

Fix [compatibility issue](https://tickets.puppetlabs.com/browse/PUP-1597) with Puppet versions between 3.4 and 3.6

### 0.5.3

Removed `root_path` parameter from main class (redundant with `catalina_home`)

### 0.5.2

* `installation_support` renamed to `install_from`
* New debugging parameters: `jpda_enable`, `jpda_transport`, `jpda_address`, `jpda_suspend` and `jpda_opts`

### 0.5.1

* `tomcat_user` defaults to `service_name` if installed from package
* Log name in Access Log valve now matches `hostname`
* Fixed log folder permissions

### 0.5.0

* Support SuSE OS family
* Configures instance admin webapps properly when installed from archive
* Does not uninstall unrequired libraries anymore (native, log4j)
* Improve warning logging
* Cleanup

### 0.4.1

* Document missing parameter `installation_support`
* Improve documentation

### 0.4.0

* Support installation from archive
* Use `nanliu/staging` instead of `nanliu/archive` to download and extract files
* Improved systemd support
* `create_default_admin` defaults to `false`
* Numerous improvements in code and documentation

### 0.3.2

New parameter `manage_firewall`

### 0.3.1

* `java_opts` and `catalina_opts` are now array parameters
* Path to "setenv" file can be set using `config_path`
* `extras` renamed to `enable_extras`
* `tomcat_native` and `log4j` default to false

### 0.3.0

**Warning:** this release is a big step forward, please read the documentation carefully

* New type `tomcat::instance`, allows creation of individual instances
* Old `log4j` parameter now split between `log4j` (package) and `log4j_enable` (conf)
* New parameters `apr_listener`, `apr_sslengine`
* Removed parameters `logfile_days` and `logfile_compress`
* Reorganized files and templates
* Fixed broken init script (service status check)
* Use `nanliu/archive` module to download extra libraries

### 0.2.1

* New parameters `logfile_days` and `logfile_compress`
* Added log rotation
* `catalina_base` defaults to `catalina_home` on RedHat (inverted the logic)
* merged Debian and RedHat main configuration files

### 0.2.0

* New parameter `jmx_bind_address`
* `catalina_home` now defaults to `catalina_base` on RedHat
* Removed `defaulthost` parameter
* Minor improvements in code quality, documentation and metadata 

### 0.1.0

* Support Debian/Ubuntu
* Renamed `enable_manager` parameter to `admin_webapps`
* New parameters `admin_webapps_package_name` and `log4j_package_name`

### 0.0.4

Stop managing tomcat user, RPMs already take care of it

### 0.0.3

* The package name for Tomcat native library can now be set
* Notify tomcat service when a package resource is modified

### 0.0.2

Fixed a bug with 'extras' libraries get path

### 0.0.1

First forge release
