<%
@rule_list.each do |rule| 
  if @ipversion.to_i == 4 then
    next if (rule.has_key?('src') && rule['src'].include?(':'))
    next if (rule.has_key?('dst') && rule['dst'].include?(':'))
   end
  if @ipversion.to_i == 6 then
    next if (rule.has_key?('src') && rule['src'].include?('.'))
    next if (rule.has_key?('dst') && rule['dst'].include?('.'))
   end
-%>
-A <%= rule['chain'] -%>
  <%- if rule.has_key?('inif') %> -i <%= rule['inif'] %><% end -%>
  <%- if rule.has_key?('outif') %> -o <%= rule['outif'] %><% end -%>
  <%- if rule.has_key?('inint') %> -i <%= rule['inint'] %><% end -%>
  <%- if rule.has_key?('outint') %> -o <%= rule['outint'] %><% end -%>
  <%- if rule.has_key?('src') %> -s <%= rule['src'] %><% end -%>
  <%- if rule.has_key?('dst') %> -d <%= rule['dst'] %><% end -%>
  <%- if rule.has_key?('protocol') %> -p <%= rule['protocol'] %><% end -%>
  <%- if rule.has_key?('port') %> --dport <%= rule['port'] %><% end -%>
  <%- if rule.has_key?('sport') %> --sport <%= rule['sport'] %><% end -%>
  <%- if rule.has_key?('dport') %> --dport <%= rule['dport'] %><% end -%>
  <%- if rule.has_key?('target') %> -j <%= rule['target'] %><% end %>
<% end -%>
