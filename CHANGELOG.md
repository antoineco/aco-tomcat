###1.0.3

Fix regression due to changes in pid file management

###1.0.2

* Add missing `ensure` attributes ([hanej](https://github.com/hanej))
* Don't force pid file creation (fixes startup issue with Tomcat 6)

###1.0.1

Fix documentation format and add Context config example

###1.0.0

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

###0.9.3

* Allow several instances to use the same `log_path`
* Parameters validation
* Partial spec tests

###0.9.2

* Enable multi-version tomcat installation
* New parameter `log_path`: define log directory
* Fix issue with generic init script always returning 0

###0.9.1

Fix compatibility with future parser in Puppet 3.7.4 ([PUP-3615](https://tickets.puppetlabs.com/browse/PUP-3615))

###0.9.0

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

###0.8.2

* New parameters related to Executors
 - `threadpool_name`
 - `threadpool_nameprefix`
 - `threadpool_maxthreads`
 - `threadpool_minsparethreads`
 - `threadpool_params`
 - `executors`

###0.8.1

* Fix Critical messages generated when concaneting empty fragments to server.xml
* New parameter `valves`: create custom Valve components within the server configuration
* Change default value for `catalina_pid` (instance context) and manage pid file
* Improve template formatting

###0.8.0

* Numerous new Connector parameters (see documentation, thanks [etlweather](https://github.com/etlweather) for the help)
* Split bulky server.xml template into independant fragments
* New `context_resources` parameter: add ResourceLink elements to context.xml ([etlweather](https://github.com/etlweather))
* Added basic support for SimpleTcpCluster ([etlweather](https://github.com/etlweather), experimental and undocumented, need contributions)
* Updated documentation

###0.7.0

* New realm parameters: `$lockout_realm`, `$userdatabase_realm` ([etlweather](https://github.com/etlweather))
* New `globalnaming_resources` and `realms` parameters: possibility to define custom GlobalNamingResources and Realm elements ([etlweather](https://github.com/etlweather))
* Changed `root_path` default value (instance context)
* Proper startup script for distributions without systemd
* Better support of SuSE OS family
* Fix tomcat6 startup script on RHEL (warning: now requires stdlib >= 4.4.0)

###0.6.0

* Compatible with future parser
* Minor code improvements

###0.5.4

Fix [compatibility issue](https://tickets.puppetlabs.com/browse/PUP-1597) with Puppet versions between 3.4 and 3.6

###0.5.3

Removed `root_path` parameter from main class (redundant with `catalina_home`)

###0.5.2

* `installation_support` renamed to `install_from`
* New debugging parameters: `jpda_enable`, `jpda_transport`, `jpda_address`, `jpda_suspend` and `jpda_opts`

###0.5.1

* `tomcat_user` defaults to `service_name` if installed from package
* Log name in Access Log valve now matches `hostname`
* Fixed log folder permissions

###0.5.0

* Support SuSE OS family
* Configures instance admin webapps properly when installed from archive
* Does not uninstall unrequired libraries anymore (native, log4j)
* Improve warning logging
* Cleanup

###0.4.1

* Document missing parameter `installation_support`
* Improve documentation

###0.4.0

* Support installation from archive
* Use `nanliu/staging` instead of `nanliu/archive` to download and extract files
* Improved systemd support
* `create_default_admin` defaults to `false`
* Numerous improvements in code and documentation

###0.3.2

New parameter `manage_firewall`

###0.3.1

* `java_opts` and `catalina_opts` are now array parameters
* Path to "setenv" file can be set using `config_path`
* `extras` renamed to `enable_extras`
* `tomcat_native` and `log4j` default to false

###0.3.0

**Warning:** this release is a big step forward, please read the documentation carefully

* New type `tomcat::instance`, allows creation of individual instances
* Old `log4j` parameter now split between `log4j` (package) and `log4j_enable` (conf)
* New parameters `apr_listener`, `apr_sslengine`
* Removed parameters `logfile_days` and `logfile_compress`
* Reorganized files and templates
* Fixed broken init script (service status check)
* Use `nanliu/archive` module to download extra libraries

###0.2.1

* New parameters `logfile_days` and `logfile_compress`
* Added log rotation
* `catalina_base` defaults to `catalina_home` on RedHat (inverted the logic)
* merged Debian and RedHat main configuration files

###0.2.0

* New parameter `jmx_bind_address`
* `catalina_home` now defaults to `catalina_base` on RedHat
* Removed `defaulthost` parameter
* Minor improvements in code quality, documentation and metadata 

###0.1.0

* Support Debian/Ubuntu
* Renamed `enable_manager` parameter to `admin_webapps`
* New parameters `admin_webapps_package_name` and `log4j_package_name`

###0.0.4

Stop managing tomcat user, RPMs already take care of it

###0.0.3

* The package name for Tomcat native library can now be set
* Notify tomcat service when a package resource is modified

###0.0.2

Fixed a bug with 'extras' libraries get path

###0.0.1

First forge release
