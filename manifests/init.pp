# == Class: iptables
#
# This class allows to manage iptables rules. It installs required iptables
# packages, generates a ruleset in iptables-save/restore format and applies
# them.
#
# === Parameters
#
# See README.md
#
# === Authors
#
# - Vaidas Jablonskis <jablonskis@gmail.com>
#
class iptables(
  $onboot                    = true,
  $package                   = 'installed',
  $ruleset                   = hiera_hash('iptables::rules', undef),
  $filter_input_policy       = 'ACCEPT',
  $filter_output_policy      = 'ACCEPT',
  $filter_forward_policy     = 'ACCEPT',
  $nat_prerouting_policy     = 'ACCEPT',
  $nat_input_policy          = 'ACCEPT',
  $nat_output_policy         = 'ACCEPT',
  $nat_postrouting_policy    = 'ACCEPT',
  $mangle_prerouting_policy  = 'ACCEPT',
  $mangle_output_policy      = 'ACCEPT',
  $mangle_forward_policy     = 'ACCEPT',
  $mangle_input_policy       = 'ACCEPT',
  $mangle_postrouting_policy = 'ACCEPT',
) {
  case $::operatingsystem {
    Fedora: {
      $package_name = ['iptables', 'iptables-services']
      $service_name = 'iptables'
      $ipt_restore  = '/usr/sbin/iptables-restore'
      $config_file  = '/etc/sysconfig/iptables'
    }
    Debian,Ubuntu: {
      $package_name = ['iptables', 'iptables-persistent']
      $service_name = 'iptables-persistent'
      $ipt_restore  = '/sbin/iptables-restore'
      $config_file  = '/etc/iptables/rules.v4'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}.")
    }
  }

  $conf_template = 'iptables.erb'

  package { $package_name:
    ensure => $package,
  }

  file { $config_file:
    ensure  => file,
    require => Package[$package_name],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/${conf_template}"),
    notify  => Exec['iptables_rules_restore'],
  }

  exec { 'iptables_rules_restore':
    path        => '/sbin:/usr/sbin',
    command     => "iptables-restore < ${config_file}",
    refreshonly => true,
  }

  service { $service_name:
    enable  => $onboot,
    require => [ Package[$package_name],
                 File[$config_file] ],
  }
}
