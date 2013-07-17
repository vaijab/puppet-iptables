iptables
===

Iptables module allows to manage iptables rules. It installs required iptables
packages, generates a ruleset in iptables-save/restore format and applies
them.

It gives great flexibility when used with hiera.


## Class: iptables

### Parameters
* `onboot` - whether to enable or disable iptables rules on boot. Valid values:
`true`, `false` or `manual`. Default: `true`.

* `package` - used to specify what version of the package should be used.
Valid values: `installed`, `absent` or specific package version. Default:
`installed`.

* `chains` - a hash of hashes. Each hash represents a single custom iptables chain.
Default and valid hash parameters and values. 
  * `table` - table name. Default: `filter`.
  * `chain` - custom chain name. Default: `nil`. If you do not specify a `chain`
    parameter then the custom chain will not be created.

* `rules` - a hash of hashes. Each hash represents a single iptables rule. `nil`
parameter value means that this parameter will be excluded from a generated rule.
Default and valid hash parameters and values. 
  * `table` - table name. Default: `filter`.
  * `chain` - chain name. Default: `INPUT`.
  * `in_int` - incoming traffic interface. Default: `nil`.
  * `out_int` - outgoing traffic interface. Default: `nil`.
  * `src` - source host or list of hosts. Default: `nil`.
  * `dst` - destination host or list of hosts. Default: `nil`.
  * `proto` - layer4 protocol. Default: `nil`.
  * `sport` - source port. Default: `nil`.
  * `dport` - destination port. Default: `nil`.
  * `match` - match module. Default `nil`.
  * `match_param` - match parameters. Default: `nil`.
  * `action`: target to jump to. Default: `ACCEPT`.

* `filter_input_policy` - filter table INPUT chain default policy. Default: `ACCEPT`.
* `filter_output_policy` - filter table OUTPUT chain default policy. Default: `ACCEPT`.
* `filter_forward_policy` - filter table FORWARD chain default policy. Default: `ACCEPT`.
* `nat_prerouting_policy` - nat table PREROUTING chain default policy. Default: `ACCEPT`.
* `nat_input_policy`- nat table INPUT chain default policy. Default: `ACCEPT`.
* `nat_output_policy` - nat table OUTPUT chain default policy. Default: `ACCEPT`.
* `nat_postrouting_policy` - nat table POSTROUTNG chain default policy. Default: `ACCEPT`.
* `mangle_prerouting_policy` - mangle table PREROUTING chain default policy. Default: `ACCEPT`.
* `mangle_output_policy` - mangle table OUTPUT chain default policy. Default: `ACCEPT`.
* `mangle_forward_policy` - mangle table FORWARD chain default policy. Default: `ACCEPT`.
* `mangle_input_policy` - mangle table INPUT chain default policy. Default: `ACCEPT`.
* `mangle_postrouting_policy` - mangle table POSTROUTING chain defaut policy. Default: `ACCEPT`.

### Examples

    ---
    classes:
      - 'iptables'
    
    iptables::filter_input_policy: DROP
    
    iptables::chains:
      '010_custom_chain_OURHOSTS':
        chain: OURHOSTS
    
    iptables::rules:
      '002_add_our_hosts_to_OURHOSTS':
        chain: OURHOSTS
        src: '192.168.0.0/24,1.2.3.4'
      '010_allow_established_related':
        match: conntrack
        match_param: '--ctstate ESTABLISHED,RELATED'
      '020_allow_lo':
        in_int: lo
      '030_allow_ssh':
        proto: tcp
        dport: 22
        action: OURHOSTS
      '999_drop_all':
        action: DROP


## Limitations
* Cannot correct a ruleset if someone manually inserts/removes rules via command line.
* No IPv6 support, but should be fairly easy to extend the module to support it.
* No easy way to use multiple match module within a single rule.


# Authors
* Vaidas Jablonskis <jablonskis@gmail.com>

