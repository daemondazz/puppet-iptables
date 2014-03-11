define iptables::rulefile ($ipversion=4) {
    if ($iptables_trusted_chain) {
        $trusted_chain = $iptables_trusted_chain
    } else {
        $trusted_chain = 'TRUSTED'
    }

    concat { $savefile:
        owner  => root,
        group  => root,
        mode   => 0644,
        notify => Exec["reload_iptables${ipversion}"],
    }

    concat::fragment { "iptables${ipversion}_puppet_note" :
        target  => $savefile,
        order   => 01,
        content => template('puppet_header.tpl')
    }

    concat::fragment { "iptables${ipversion}_filter_header" :
        target => $savefile,
        order  => 10,
        content => template("iptables/filter_header.tpl")
    }

    concat::fragment { "iptables${ipversion}_filter_global_trusted_hosts" :
        target => $savefile,
        order  => 15,
        content => inline_template("<% iptables_global_trusted_hosts.each do |host| %>-A INPUT -s <%= host %> -j <%= trusted_chain %>\n<% end %>")
    }

    if ($iptables_local_trusted_hosts) {
        concat::fragment { "iptables${ipversion}_filter_local_trusted_hosts" :
            target => $savefile,
            order  => 20,
            content => inline_template("<% iptables_local_trusted_hosts.each do |host| %>-A INPUT -s <%= host %> -j <%= trusted_chain %>\n<% end %>")
        }
    }

    iptables::rulelist { "iptables${ipversion}_filter_global_rules" :
        target => $savefile,
        order => 25,
        rule_list => $iptables_global_rules
    }

    if ($iptables_local_filter_rules) {
        iptables::rulelist { "iptables${ipversion}_filter_local_rules" :
            target => $savefile,
            order => 30,
            rule_list => $iptables_local_filter_rules
        }
    }

    concat::fragment { "iptables${ipversion}_filter_footer" :
        target => $savefile,
        order  => 35,
        content => "COMMIT\n"
    }


    #
    # Parse any MANGLE rules defined.
    #
    if ($iptables_local_mangle_rules) {
        concat::fragment { "iptables${ipversion}_mangle_header" :
            target => $savefile,
            order  => 50,
            content => template('iptables/mangle_header.tpl')
        }
        iptables::rulelist { "iptables${ipversion}_mangle_body" :
            target => $savefile,
            order => 55,
            rule_list => $iptables_local_mangle_rules
        }
        concat::fragment { "iptables${ipversion}_mangle_footer" :
            target  => $savefile,
            order   => 60,
            content => "COMMIT\n"
        }
    }


    #
    # Also parse any NAT rules defined. Requires we are building the IPv4 file.
    #
    if ($iptables_local_nat_rules) {
        if ($ipversion == 4) {
            concat::fragment { "iptables${ipversion}_nat_header" :
                target => $savefile,
                order  => 80,
                content => template('iptables/nat_header.tpl')
            }
            iptables::rulelist { "iptables${ipversion}_nat_body" :
                target => $savefile,
                order => 85,
                rule_list => $iptables_local_nat_rules
            }
            concat::fragment { "iptables${ipversion}_nat_footer" :
                target  => $savefile,
                order   => 90,
                content => "COMMIT\n"
            }
        }
    }

}
