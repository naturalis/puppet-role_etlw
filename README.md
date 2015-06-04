puppet-role_etlw
===================

Puppet role definition for deployment of ETL Workbench

Parameters
-------------
Sensible defaults for Naturalis in init.pp.

```
  docroot                                 = documentroot
  webdirs                                 = Array with webdirectories, 0750 permissions will be applied owner: root  group: www-data
  mysql_root_password                     = Mysql Root password
  instances                               = Instance hash, see the default for parameters
  enable_phpmyadmin                       = Enable PhpMyAdmin, only use this on development systems for easy database access and testing
  coderepo                                = Code repository location
  repotype                                = Repository Type
  repoversion                             = Repository checkout method ( present, latest etc)
  repokey                                 = Repository Private key used for access
  repokeyname                             = Name of the key for usage in ssh config
  repodir                                 = Directory repo will be cloned to. ( within docroot )
  dbName                                  = Database name
  dbUser                                  = Database user
  dbPassword                              = Database password
  mysql_manage_config_file                = Manage mysql config ( true or false )
  mysql_key_buffer_size                   = mysql configurable parameter
  mysql_query_cache_limit                 = mysql configurable parameter
  mysql_query_cache_size                  = mysql configurable parameter
  mysql_innodb_buffer_pool_size           = mysql configurable parameter
  mysql_innodb_additional_mem_pool_size   = mysql configurable parameter
  mysql_innodb_log_buffer_size            = mysql configurable parameter
  mysql_max_connections                   = mysql configurable parameter
  mysql_max_heap_table_size               = mysql configurable parameter
  mysql_lower_case_table_names            = mysql configurable parameter
  mysql_innodb_file_per_table             = mysql configurable parameter
  mysql_tmp_table_size                    = mysql configurable parameter
  mysql_table_open_cache                  = mysql configurable parameter
  php_memory_limit                        = php configurable parameter
  php_upload_max_filesize                 = php configurable parameter
  php_post_max_size                       = php configurable parameter
  php_max_execution_time                  = php configurable parameter
  php_max_input_vars                      = php configurable parameter
  php_session_save_path                   = php configurable parameter
  php_xdebug_max_nesting_level            = php configurable parameter
  php_default_charset                     = php configurable parameter
  php_ini_files                           = array with php ini files
  $instances                              = instance array ( example below ). Change IP rewrite rule for hostname and change etlw to match repodir
          {'site.etlwsite.nl' => {
            'serveraliases'   => '*.etlwsite.nl',
            'docroot'         => '/var/www/htdocs',
            'directories'     => [{ 'path' => '/var/www/htdocs', 'options' => '-Indexes +FollowSymLinks +MultiViews', 'allow_override' => 'All' }],
            'aliases'         => [{ 'alias' => '/etlw', 'path' => '/var/www/htdocs/etlw/public'}],
            'rewrites'        => [{ 'rewrite_cond' => '%{REQUEST_URI} ^/$', 'rewrite_rule' => '(.*) http://10.42.1.196/etlw [R=301,L]'}],
            'port'            => 80,
            'serveradmin'     => 'webmaster@naturalis.nl',
            'priority'        => 10,
            },
          },

```


Classes
-------------
- role_etlw
- role_etlw::instances
- role_etlw::build


Dependencies
-------------
- puppetlabs/mysql
- puppetlabs/apache
- puppetlabs/concat
- thias/php


Puppet code
```
class { role_etlw: }
```
Result
-------------
Working ETL Workbench, running on LAMP Stack


Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.

The module has been tested on:
- Ubuntu 14.04LTS

Dependencies releases tested: 
- puppetlabs/mysql 3.3.0
- puppetlabs/apache 1.3.0
- puppetlabs/concat 1.2.0
- thias/php 1.0.0


