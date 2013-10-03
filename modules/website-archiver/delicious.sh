# :Date: 2013-09-28
# :Version: 1
# :Author: Bazyli Brzoska
# :Variables: - DELICIOUS_API_KEY
#             - DELICIOUS_LOGIN
#             - DELICIOUS_PASSWORD
# :Description: takes all tasks tagged **!archive**, 
#               makes a local copy of them 
#               
#               and renames the tag **!archive** to **!local-copy**
#
non_default_setting_needed DELICIOUS_API_KEY DELICIOUS_LOGIN DELICIOUS_PASSWORD DELICIOUS_SYSTEM_USER
sanei_resolve_dependencies jq apt:curl

local delicious_url;
local delicious_json;
local delicious_link_name;
local delicious_link_url;
local delicious_link_domain;

# cd /tmp
# tutaj mamy dluzszy komentarz
# 
# i przerwa
#wget -O "this.json"

delicious_url="http://feeds.delicious.com/v2/json/$DELICIOUS_LOGIN/!archive?count=100&private=$DELICIOUS_API_KEY"
delicious_json=$(curl "$delicious_url")
delicious_count=$(echo $delicious_json | jq -r '. | length')
delicious_archived=0
while [[ delicious_count -gt 0 ]]; do
	((delicious_count--))
	delicious_link_name=$(echo $delicious_json | jq ".[$delicious_count].d" | tr A-Z a-z | sed -r 's/[^a-zA-Z0-9\-]+/_/g')
	delicious_link_url=$(echo $delicious_json | jq ".[$delicious_count].u")
	delicious_link_url=${delicious_link_url:1:${#delicious_link_url}-2}
	delicious_link_domain=$(echo $delicious_json | jq ".[$delicious_count].u" | awk -F/ '{print $3}')
	info "Processing: $delicious_link_name ($delicious_link_url)"
	sanei_invoke_module_script website-archiver archive $delicious_link_url "$delicious_link_domain/$delicious_link_name"
	((delicious_archived++))
done

# cleanup
if [[ delicious_archived -gt 0 ]]; then
	curl "http://$DELICIOUS_LOGIN:$DELICIOUS_PASSWORD@feeds.delicious.com/v1/tags/rename?old=!archive&new=!local-copy"
fi
