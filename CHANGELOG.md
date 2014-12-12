###0.3.0

**Warning:** this release is a big step forward, please read the documentation carefully

* New type `tomcat::instance`, allows creation of individual instances
* Old `log4j` parameter now split between `log4j` (package) and `log4j_enable` (conf)
* New parameters `apr_listener`, `apr_sslengine`
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

* Stop managing tomcat user, RPMs already take care of it

###0.0.3

* The package name for Tomcat native library can now be set
* Notify tomcat service when a package resource is modified

###0.0.2

Fixed a bug with 'extras' libraries get path

###0.0.1

First forge release
