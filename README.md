# mw_php_fpm library cookbook

[![Build Status](https://travis-ci.org/Mikroways/mw_php_fpm.svg?branch=master)](https://travis-ci.org/Mikroways/mw_php_fpm)

As many applications depends on older PHP versions, sometimes, the only way to
configure those applications using newer platforms is via Docker.
This cookbooks provides a resource that will abstract the way you can configure
php-fpm by native packages or using docker

Requirements
------------

* Chef 12+

Cookbook dependencies
---------------------

* docker
* php-fpm

Usage
-----

Place a dependency on the mw_php_fpm cookbook in your cookbook's metadata.rb

```ruby
  depends 'mw_php_fpm', '~> 0.1.0'
```

Then if you want a docker php-fpm, then:

```ruby
  mw_php_fpm_docker 'fpm-pool-name' do
    session_dir '/opt/myapp/fpm/session'
    prefix '/opt/myapp/current'
    listen '/opt/myapp/fpm/socket'
    user 'www-data'
    config_file '/opt/myapp/fpm/fpm.conf'
    repo '5.5-fpm'
    volumes [ '/opt/myapp:/opt/myapp' ]
  end
```

If you want a native php-fpm pool, then:

```ruby
  mw_php_fpm 'fpm-pool-name' do
    session_dir '/opt/myapp/fpm/session'
    listen '/opt/myapp/fpm/socket'
    user 'www-data'
  end
```

Resources overview
------------------

### mw_php_fpm

Will install php-fpm as a native package allowing to define pools of fpm

### Parameters

* `name`: name of resource
* `session_dir`: directory where php sessions will be saved
* `session_lifetime`: lifetime of php sessions. Default to 24 minutes
* `listen`: socket unix path or port to listen for incoming connections
* `listen_owner`: when socket unix, owner of socket file
* `listen_group`: when socket unix, group of socket file
* `listen_mode`: when socket unix, permission of socket file
* `allowed_clients`: when tcp socket, addresses to allow connections from
* `user`: user to run php-fpm pool as
* `group`: group to run php-fpm pool as
* `process_manager`: type of process_manager. Defaults to dynamic
* `max_children`: default 30
* `start_servers`: default 4
* `min_spare_servers`: default 2
* `max_spare_servers`: default 6
* `max_requests`: default 500
* `catch_workers_output`: default true
* `security_limit_extensions`: default `.php`
* `access_log`: defines access log file
* `request_terminate_timeout`: default 0
* `php_options`: hash of php_options to change `php.ini` defaults. Allways will
  add `php_admin_value[session.save_path]` set to `session_dir`

### mw_php_fom_docker

Will install docker as a service and some image used to provide fpm service.
Useful when required php version doesn't match the one provided natively by
the running platform

### Parameters

* `prefix`: prefix for php-fpm
* `config_file`: php-fpm template to be mounted as docker volume
* `repo`: docker image to use as php-fpm
* `run_as_user`: run container as specific user?. Defaults to true
* `command`: command to run inside container. Defaults to `php-fpm --fpm-config #{resource.config_file}"`
* `volumes`: array of volumes to mount as docker volumes. See docker cookbook

