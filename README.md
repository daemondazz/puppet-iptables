# iptables module for Puppet

This is puppet module for configuring iptables on servers. It supports
configuring a mixture of IPv4 and IPv6 trusted hosts and firewall rules at both
a global and per-host level.

## Puppet Classes

The following classes are defined in this modules. Please note that only
`iptables::ipv4` and `iptables::ipv6` should actually be needed externally.

1. `iptables`
    Top level class

2. `iptables::ipv4`

    Includes IPv4 firewall rule for the node. Likely should be instantiated for
    node.

3. `iptables::ipv6`
    Includes IPv6 firewall rule for the node. Likely should be instantiated for
    node if IPv6 is available.

4. `iptables::rulefile`
    Instantiated by `iptables::ipv4` and `iptables::ipv6` to build the rule
    file for the node using concat.

5. `iptables::rulelist`
    Instantiated by `iptables::rulefile` to build fragments for the global and
    local filter, nat and mangle rulesets. Handles detecting IPv4 and IPv6
    hosts in the ruleset and only including the appropriate rules.

## Puppet Variables

The following variables are utilised by the puppet module and included
templates. These variables may be set either globally or locally within the
node. The expected location and variable type for each setting is shown in
brackets.

1. `$iptables_global_rules` (global - array of hashes)
    A list of rules that will be installed onto every host. Please see rule
    list syntax for supported options for the rule list.

2. `$iptables_global_trusted_hosts4` (global - array)
    A list of IPv4 addresses that will be included in a jump to the TRUSTED
    table on every node.

3. `$iptables_global_trusted_hosts6` (global - array) 
    A list of IPv6 addresses that will be included in a jump to the TRUSTED
    table on every node.

4. `$iptables_ntp` (node - boolean) 
    A flag indicating whether the access and rate limiting rules for NTP are
    applied to this node. Recommended for any public node exposing NTP.

5. `$iptables_local_chains` (node - array)
    If defined, a list of extra chains that are used in the local rules for the
    node. Note that the chains will be created in all of the filter, nat and
    mangle tables, if they are created.

6. `$iptables_local_filter_rules` (node - array of hashes)
    A list of rules that will be installed onto every host. Please see rule
    list syntax for supported options for the rule list.

7. `$iptables_local_mangle_rules` (node - array of hashes)
    A list of rules that will be installed into the MANGLE table on the node.
    Please see rule list syntax for supported options for the rule list.

8. `$iptables_local_nat_rules` (node - array of hashes)
    A list of rules that will be installed into the NAT table on the node.
    Ignored for IPv6. Please see rule list syntax for supported options for the
    rule list.

9. `$iptables_local_trusted_hosts4` (node - array) 
    A list of IPv4 addresses that will be included in a jump to the TRUSTED
    table on this node.

10. `$iptables_local_trusted_hosts6` (node - array) 
    A list of IPv6 addresses that will be included in a jump to the TRUSTED
    table on this node.

11. `iptables_ssh_port` (global or node - integer)
    If defined, automatically includes a rule in the TRUSTED table allowing
    connections to this TCP port.

12. `$iptables_trusted_chain` (global - string)
    The name of the trusted chain. If not provided defaults to 'TRUSTED'.

## Rule List

Each element of the rule list supports the following options:

* `chain` (required)
    Chain for the rule (iptables `-A` option)

* `dst`
    Destination IP address for the rule. Automatically handles IPv4 and IPv6
    addresses in the appropriate rule files (iptables `-d` option)

* `inif`
    Inbound interface for the rule. (iptables `-i` option)

* `outif`
    Outbound interface for the rule. (iptables `-o` option)

* `port` and `dport`
    Destination port for the rule. `port` is recommended, although if `sport`
    is used then `dport` may be used to explicitly state it's the destination
    port. (iptables `--dport` option)

* `protocol`
    Packet protocol for the rule. (iptables `-p` opton)

* `sport`
    Source port for the rule. (iptables `--sport` option)

* `src`
    Source IP address for the rule. Automatically handles IPv4 and IPv6
    addresses in the appropriate rule files (iptables `-s` option)

* `target`
    Jump target for the rule. (iptables `-J` option)

## Examples

### site.pp

This example renames the local trusted chain to LOCAL_TRUSTED, sets up the
global trusted host list for both IPv4 and IPv6 and sets up rules that will be
installed on every host allowing access to the SNMP server from the trusted
subnets.

    $iptables_trusted_chain = 'LOCAL_TRUSTED'
    $iptables_global_trusted_hosts4 = [
        '192.168.1.0/24',
    ]
    $iptables_global_trusted_hosts6 = [
        '2001:db8::/32',
    ]
    $iptables_global_rules = [
        { chain => 'LOCAL_TRUSTED', target => 'ACCEPT', protocol => 'udp', port => 161 },
    ]

### node

This example sets that the host is running an NTP server, the SSH port for the
host, defines a new chain that will be created for both IPv4 and IPv6 and then
defines filter and nat rules.

In this case, the host is a Ganeti master server running NTP, and it
automatically forwards VNC connections on the Ganeti cloud IP (192.168.16.10)
to the host running the VM. This requires a second script to populate the
GANETI_VNC chain - see the AFoYI iptables-ganeti repository for details.

    node ganeti_master {
        $iptables_ntp = true
        $iptables_ssh_port = 2222
        $iptables_local_chains = [
            'GANETI_VNC',
        ]
        $iptables_local_filter_rules = [
            { chain => 'INPUT', target => 'ACCEPT', protocol => 'tcp', port => 443 },
            { chain => 'LOCAL_TRUSTED', target => 'ACCEPT', protocol => 'udp', port => 514 },
            { chain => 'LOCAL_TRUSTED', target => 'ACCEPT', protocol => 'tcp', port => 514 },
        ]
        $iptables_local_nat_rules = [
            { chain => 'PREROUTING', target => 'GANETI_VNC', dst => '192.168.16.10', protocol => 'tcp', port => '11000:11500' },
            { chain => 'POSTROUTING', target => 'MASQUERADE', outif => 'eth1', dst => '10.254.254.11', protocol => 'tcp', port => '11000:11500' },
            { chain => 'POSTROUTING', target => 'MASQUERADE', outif => 'eth1', dst => '10.254.254.12', protocol => 'tcp', port => '11000:11500' },
            { chain => 'POSTROUTING', target => 'MASQUERADE', outif => 'eth1', dst => '10.254.254.13', protocol => 'tcp', port => '11000:11500' },
        ]
        include 'iptables::ipv4'
        include 'iptables::ipv6'
    }
