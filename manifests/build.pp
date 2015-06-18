# == Class: role_etlw::repo
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_etlw::build ()
{

# ensure git package for build checkouts
  package { 'git':
    ensure => installed,
  }

# set local variable for template sshconfig.erb
$repokeyname = $role_etlw::repokeyname

# Create /root/.ssh directory
  file { '/root/.ssh':
    ensure    => directory,
  }->
# Create /root/.ssh/buildkeyname file
  file { "/root/.ssh/${role_etlw::repokeyname}":
    ensure    => present,
    content   => $role_etlw::repokey,
    mode      => '0600',
  }->
# Create sshconfig file
  file { '/root/.ssh/config':
    ensure    => present,
    content   =>  template('role_etlw/sshconfig.erb'),
    mode      => '0600',
  }->
# copy known_hosts.sh file from puppet module
  file{ '/usr/local/sbin/known_hosts.sh' :
    ensure    => present,
    mode      => '0700',
    source    => 'puppet:///modules/role_etlw/known_hosts.sh',
  }->
# run known_hosts.sh for future acceptance of github key
  exec{ 'add_known_hosts' :
    command   => '/usr/local/sbin/known_hosts.sh',
    path      => '/sbin:/usr/bin:/usr/local/bin/:/bin/',
    provider  => shell,
    user      => 'root',
    unless    => 'test -f /root/.ssh/known_hosts'
  }->
# give known_hosts file the correct permissions
  file{ '/root/.ssh/known_hosts':
    mode      => '0600',
  }->
# checkout using vcsbuild
  vcsrepo { "${role_etlw::docroot}/${role_etlw::repodir}":
    ensure    => $role_etlw::repoversion,
    provider  => $role_etlw::repotype,
    source    => $role_etlw::coderepo,
    user      => 'root',
    revision  => $role_etlw::reporevision,
    require   => Package['git']
  }

# set local variable for buildscript.sh.erb template
  $repodir                    = $role_etlw::repodir
  $dbUser                     = $role_etlw::dbUser
  $dbName                     = $role_etlw::dbName
  $dbPassword                 = $role_etlw::dbPassword

# create .htaccess from template
  file { "${role_etlw::docroot}/${role_etlw::repodir}/public/.htaccess":
    content         => template('role_etlw/.htaccess.erb'),
    mode            => '0640',
    owner           => 'root',
    group           => 'www-data',
    require         => Vcsrepo["${role_etlw::docroot}/${role_etlw::repodir}"]
  }

# create application.ini from template
  file { "${role_etlw::docroot}/${role_etlw::repodir}/application/configs/application.ini":
    content         => template('role_etlw/application.ini.erb'),
    mode            => '0640',
    owner           => 'root',
    group           => 'www-data',
    require         => Vcsrepo["${role_etlw::docroot}/${role_etlw::repodir}"]
  }

  mysql::db { $role_etlw::dbName:
    user            => $role_etlw::dbUser,
    password        =>  $role_etlw::dbPassword,
    host            => 'localhost',
    grant           => ['SELECT', 'UPDATE'],
    sql             => "${role_etlw::docroot}/${role_etlw::repodir}/docs/sql_scripts/qaw_config.sql",
    import_timeout  => 900,
    require         => Vcsrepo["${role_etlw::docroot}/${role_etlw::repodir}"]
  }
}

