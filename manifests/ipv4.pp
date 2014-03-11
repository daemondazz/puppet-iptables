# iptables IPv4 module
class iptables::ipv4 {
    $iptables_local_trusted_hosts = $iptables_local_trusted_hosts4
    $iptables_global_trusted_hosts = $iptables_global_trusted_hosts4

    $savefile = $osfamily ? {
        RedHat  => '/etc/sysconfig/iptables',
        default => '/etc/iptables.rules'
    }
    $reload_command = $osfamily ? {
        RedHat  => '/etc/init.d/iptables restart',
        default => "/sbin/iptables-restore < ${savefile}"
    }

    exec { "reload_iptables4" :
        command     => $reload_command,
        refreshonly => true,
    }

    iptables::rulefile {
        'rulefile_ipv4' : ipversion => 4,
    }
}
