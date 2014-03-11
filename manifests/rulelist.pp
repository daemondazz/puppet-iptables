define iptables::rulelist ($target, $order, $rule_list) {
    concat::fragment { $title :
        target => $target,
        order  => $order,
        content => template("iptables/rulelist.tpl")
    }
}
