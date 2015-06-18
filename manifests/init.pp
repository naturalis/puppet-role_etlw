# == Class: role_etlw
#
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_etlw (
  $docroot                                = '/var/www/htdocs',
  $webdirs                                = ['/var/www/htdocs'],
  $coderepo                               = 'git@github.com:naturalis/qaw.git',
  $repotype                               = 'git',
  $repoversion                            = 'present',
  $repokey                                = undef,
  $repokeyname                            = 'githubkey',
  $repodir                                = 'etlw',
  $reporevision                           = 'master',
  $builddir                               = '/opt/etlw',
  $enable_phpmyadmin                      = false,
  $mysql_root_password                    = 'rootpassword',
  $dbName                                 = 'etlw',
  $dbUser                                 = 'etlw',
  $dbPassword                             = 'password',
  $mysql_manage_config_file               = true,
  $mysql_key_buffer_size                  = undef,
  $mysql_query_cache_limit                = undef,
  $mysql_query_cache_size                 = undef,
  $mysql_innodb_buffer_pool_size          = undef,
  $mysql_innodb_additional_mem_pool_size  = undef,
  $mysql_innodb_log_buffer_size           = undef,
  $mysql_max_connections                  = undef,
  $mysql_max_heap_table_size              = undef,
  $mysql_lower_case_table_names           = undef,
  $mysql_innodb_file_per_table            = undef,
  $mysql_tmp_table_size                   = undef,
  $mysql_table_open_cache                 = undef,
  $php_memory_limit                       = '512M',
  $php_upload_max_filesize                = '256M',
  $php_post_max_size                      = '384M',
  $php_max_execution_time                 = '-1',
  $php_max_input_vars                     = '3000',
  $php_session_save_path                  = '/tmp',
  $php_suhosin_request_max_vars           = '3000',
  $php_xdebug_max_nesting_level           = '500',
  $php_default_charset                    = 'utf-8',
  $php_ini_files                          = ['/etc/php5/apache2/php.ini'],
  $instances                              =
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
  $keepalive                            = 'Off',
  $max_keepalive_requests               = '100',
  $keepalive_timeout                    = '15',
){

  file { $webdirs:
    ensure                  => 'directory',
    mode                    => '0750',
    owner                   => 'root',
    group                   => 'www-data',
    require                 => Class['apache']
  }

# install php module php-gd
  php::module { [ 'gd','mysql','curl','xdebug' ]: }

# Install php cli
  php::ini { '/etc/php.ini':
  }->
  class {'php::cli':
  }

# Configure custom php settings
  php::ini { $php_ini_files:
    memory_limit                => $php_memory_limit,
    upload_max_filesize         => $php_upload_max_filesize,
    post_max_size               => $php_post_max_size,
    max_execution_time          => $php_max_execution_time,
    max_input_vars              => $php_max_input_vars,
    session_save_path           => $php_session_save_path,
    default_charset             => $php_default_charset,
    require                     => [Class['apache::mod::php'],Class['php::cli']]
  }

  php::module::ini { 'xdebug':
    prefix   => '20',
    settings => {
      'xdebug.max_nesting_level'    => $php_xdebug_max_nesting_level,
    },
    require  => [Class['apache::mod::php'],Class['php::cli']]
  }

# Install apache and enable modules
  class { 'apache':
    default_mods              => true,
    mpm_module                => 'prefork',
    keepalive                 => $keepalive,
    max_keepalive_requests    => $max_keepalive_requests,
    keepalive_timeout         => $keepalive_timeout,
  }

  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::speling

# Create instances (vhosts)
  class { 'role_etlw::instances':
      instances               => $instances,
  }

# Configure MySQL Security and finetuning if needed
  class { 'mysql::server::account_security':}
  class { 'mysql::server':
      root_password         => $mysql_root_password,
      service_enabled       => true,
      service_manage        => true,
      manage_config_file    => $mysql_manage_config_file,
      override_options      => {
        'mysqld'            => {
          'key_buffer_size'                 => $mysql_key_buffer_size,
          'query_cache_limit'               => $mysql_query_cache_limit,
          'query_cache_size'                => $mysql_query_cache_size,
          'innodb_buffer_pool_size'         => $mysql_innodb_buffer_pool_size,
          'innodb_additional_mem_pool_size' => $mysql_innodb_additional_mem_pool_size,
          'innodb_log_buffer_size'          => $mysql_innodb_log_buffer_size,
          'max_connections'                 => $mysql_max_connections,
          'max_heap_table_size'             => $mysql_max_heap_table_size,
          'lower_case_table_names'          => $mysql_lower_case_table_names,
          'innodb_file_per_table'           => $mysql_innodb_file_per_table,
          'tmp_table_size'                  => $mysql_tmp_table_size,
          'table_open_cache'                => $mysql_table_open_cache,
        }
      }
  }
# Configure phpMyadmin
  if $enable_phpmyadmin {
    package { 'phpmyadmin':
      ensure                  => 'installed',
      require                 => Package['apache2'],
      notify                  => Exec['link-phpmyadmin', 'enable-mcrypt'],
    }
    exec { 'link-phpmyadmin':
      command                 => "ln -sf /usr/share/phpmyadmin ${webdirs}/phpmyadmin",
      path                    => ['/bin'],
      require                 => File[$webdirs],
      refreshonly             => true,
    }
    exec { 'enable-mcrypt':
    command                   => 'php5enmod mcrypt',
    path                      => ['/bin', '/usr/bin', '/usr/sbin'],
    require                   => Package['phpmyadmin', 'apache2'],
    refreshonly               => true,
    notify                    => Service['apache2'],
  }
  }

# Start Build
  class { 'role_etlw::build':
    require                  => [Class['role_etlw::instances'],Class['mysql::server']]
  }

}
