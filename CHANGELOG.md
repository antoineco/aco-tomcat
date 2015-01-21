###0.8.0

* Numerous new connector parameters (see documentation, thanks [etlweather](https://github.com/etlweather) for the help)
* Split bulky server.xml template into independant fragments
* New `context_resources` parameter: add ResourceLink elements to context.xml (by [etlweather](https://github.com/etlweather))
* Added basic support for SimpleTcpCluster (by [etlweather](https://github.com/etlweather), experimental and undocumented, need contributions)
* Updated documentation

###0.7.0

* New realm parameters: `$lockout_realm`, `$userdatabase_realm` (by [etlweather](https://github.com/etlweather))
* New `globalnaming_resources`and `realms` parameters: possibility to define custom GlobalNamingResources and Realm elements (by [etlweather](https://github.com/etlweather))
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
