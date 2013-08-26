Description
===========

Install the [Openfire Jabber server](http://www.igniterealtime.org/) from source.

# Requirements
The following Chef cookbooks should be installed:

* java
* database
* postgresql

## Supported Platforms
* CentOS, Red Hat
* Ubuntu (likely, but untested)

## Database

This *should* still work using the built-in OpenFire database instead of using PostGreSQL. However this needs to be tested.

# Attributes
All attributes are optional

## Installation
* `node[:openfire][:install_method]` : install method. `rpm` or `source`. if platform is rhel or centos, default is rpm. else default is source.
* `node[:openfire][:version]`: current version
* `node[:openfire][:release]`: current release ( rpm install only )
* `node[:openfire][:source_tarball]`: currently defaults to `openfire_3_8_1.tar.gz`
    * This tarball will automatically be downloaded and installed
* `node[:openfire][:source_checksums]` source_tarball checksum. it is hash. key is tarball filename, and value is checksum.

* `node[:openfire][:user]`: the local user account to create and use to run the openfire process; if install method is 'rpm', default is 'daemon' (rpm default). else defaults to `openfire`
    * also see `node[:openfire][:group]`, which also if install method is 'rpm', default is `daemon`, else defaults to `openfire`
* `node[:openfire][:base_dir]`: the location on the file system to install openfire
* `node[:openfire][:config][:admin_console][:port]`: Use your web browser to connect to this port while you are first setting up openfire. Defaults to 9090.
* `node[:openfire][:config][:admin_console][:secure_port]`: Use your web browser to connect to this port after you have set up openfire for further configuration. This will require an https/SSL connection. Defaults to 9091.
* `node[:openfire][:config][:locale]`: Defaults to `en`.
* `node[:openfire][:config][:network][:interface]`: Defaults to `nil` (listen on all interfaces).

## Database
* `node[:openfire][:database][:type]`: currently only works with 'postgresql' or 'mysql'. If you want to use the built-in database (untested), do not set this.
* `node[:openfire][:database][:password]`: the database password for the Openfire user (required if database type is specified)
* `node[:openfire][:database][:name]`: default `openfire`
    * also see `[:database][:user]`, `[:database][:host]`, `[:database][:port]`, which have sane defaults


# Usage

* Optionally set the attributes mentioned in the `Attributes` section. 
* Add this to your node's run list: `recipe[openfire]`, then run Chef.
* Startup configuration is in the file `/etc/openfire/openfire.xml`
* Java certificates are in the `/etc/openfire/security` directory.

## New Installation

If you are configuring a new installation of Openfire, use your web browser to connect to your host, port 9091 (or whatever port you chose for `node[:openfire][:config][:admin_console][:port]` above). Run through the "wizard", and accept all defaults.

## Import

If you are importing an existing installation of Openfire:

* Optionally import the database
* Within `/etc/openfire/openfire.xml`, right before the line `</jive>`, add the following: `<setup>true</setup>`.

# Upgrading

This cookbook is not yet capable of automatically handling upgrades. To upgrade, follow the [official instructions](http://www.igniterealtime.org/builds/openfire/docs/latest/documentation/upgrade-guide.html).

Download and untar into /opt/openfire. Then set symbolic links:
* `ln -s /etc/openfire /opt/openfire/conf`
* `ln -s /var/log/openfire /opt/openfire/logs`
* `ln -s /etc/openfire/security /opt/openfire/resources/security`

Also copy your plugins:
* rsync -av /opt/openfire_old/plugins/ /opt/openfire/plugins/
