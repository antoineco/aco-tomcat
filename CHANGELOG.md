###0.2.0

* New parameter `jmx_bind_address`
* `catalina_home` now defaults to `catalina_base` on RedHat
* Tomcat won't install if no package matches the given `version` number
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
