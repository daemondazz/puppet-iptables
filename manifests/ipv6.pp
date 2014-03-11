# IPv6 iptables module
class iptables::ipv6 {
    $iptables_local_trusted_hosts = $iptables_local_trusted_hosts6
    $iptables_global_trusted_hosts = $iptables_global_trusted_hosts6

    $savefile = $osfamily ? {
        RedHat  => '/etc/sysconfig/ip6tables',
        default => '/etc/ip6tables.rules'
    }
    $reload_command = $osfamily ? {
        RedHat  => '/etc/init.d/ip6tables restart',
        default => "/sbin/ip6tables-restore < ${savefile}"
    }

    exec { "reload_iptables6" :
        command     => $reload_command,
        refreshonly => true,
    }

    iptables::rulefile {
        'rulefile_ipv6' : ipversion => 6,
    }
}
