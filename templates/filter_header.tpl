*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:ABUSERS - [0:0]
:<%= trusted_chain %> - [0:0]
<% if iptables_local_chains -%>
<% iptables_local_chains.each do |chain| -%>
:<%= chain %> - [0:0]
<% end -%>
<% end -%>
-A ABUSERS -m limit --limit 1/min -j LOG --log-prefix "IPTABLES ABUSER BLOCKED: " --log-level 7
-A ABUSERS -m recent --set --name abusers --rdest -j DROP
-A <%= trusted_chain %> -p tcp --dport <%= iptables_ssh_port %> -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m recent --update --seconds 3600 --name abusers --rsource -j DROP
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p <% if @ipversion.to_i == 6 then %>ipv6-<% end %>icmp -j ACCEPT
<% if iptables_ntp -%>
-A INPUT -p udp --dport 123 -j ACCEPT
-A OUTPUT -p udp --dport 123 -m recent --set --name ntp_users --rdest
-A OUTPUT -p udp --dport 123 -m recent --rcheck --seconds 2 --hitcount 20 --name ntp_users --rdest -j ABUSERS
<% end -%>
