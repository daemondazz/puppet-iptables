*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
<% if iptables_local_chains -%>
<% iptables_local_chains.each do |chain| -%>
:<%= chain %> - [0:0]
<% end -%>
<% end -%>
